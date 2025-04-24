ACCOUNT_ID := $(shell aws sts get-caller-identity --query Account --output text)
REGION := us-east-1
REPO_NAME := ascan_challenge_repo
IMAGE := $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(REPO_NAME)
IMAGE_TAG=latest
TF_DIR := src/terraform

.PHONY: build login tag push deploy terraform_apply clean help

## Build local
build: 
	@echo "🐳 Building the image"
	DOCKER_BUILDKIT=0 docker build -t $(REPO_NAME) src/app

## Logs in ECR
login: 
	@echo "🔐 Logging in Amazon ECR"
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com

## Tags the image
tag:
	@echo "Tagging the image"
	docker tag $(REPO_NAME):latest $(IMAGE):latest

## Sends to ECR container
push: login build tag
	@echo "🚀 Sending image to ECR..."
	docker push $(IMAGE):$(IMAGE_TAG)

terraform_apply:
	@echo "🌍 Applying Terraform infrastructure..."
	cd $(TF_DIR) && terraform init && terraform apply -auto-approve

## Deploy everything
deploy: terraform_apply push


## Clean everything
clean:
	@echo "🧹 Cleaning up..."
	@echo "🧼 Removing Docker images..."
	docker rmi -f $(REPO_NAME):latest || true
	docker rmi -f $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(REPO_NAME):latest || true
	
	@echo "🚮 Destroying Terraform infrastructure..."
	cd $(TF_DIR) && terraform destroy -auto-approve || ( echo "❌ Failed to destroy Terraform infrastructure" && exit 1 )

	@echo "✅ Clean-up completed."

## Help for commands
help:
	@echo ""
	@echo "Available commands:"
	@echo "  make create-ecr  - Creates the Amazon ECR Repository"
	@echo "  make build       - Locally builds the image"
	@echo "  make login       - Logs in into ECR"
	@echo "  make tag         - Tags the image with the repo name"
	@echo "  make push        - Executes everything"
	@echo "  make clean       - Cleans up everything"
	@echo ""