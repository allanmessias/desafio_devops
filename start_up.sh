#!/bin/bash
if command -v yum > dev/null 2>&1; then
    PKG_MANAGER="yum"
elif command -v apt > dev/null 2>&1; then
    PKG_MANAGER="apt"
else
    echo "No other package manager has been found"
fi

sudo $PKG_MANAGER update -y

if [ "$PKG_MANAGER" == "yum" ]; then
    sudo $PKG_MANAGER install -y docker
else
    sudo $PKG_MANAGER install -y docker.io
fi

sudo systemctl enable docker
sudo systemctl start docker

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"
REPO_NAME="ascan_challenge_repo"
IMAGE="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:latest"

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

docker run -d -p 80:80 $IMAGE
