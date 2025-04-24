# 🐳 Ascan Challenge – Docker Infraestrutura + Terraform + AWS ECR

This project creates a simple infrastructure using Docker and Terraform. This project only gets the server up and running and serves a HTML with Hello World within it. 

---

## 📦 Techs

- [Docker](https://www.docker.com/)
- [Terraform](https://www.terraform.io/)
- [AWS ECR (Elastic Container Registry)](https://aws.amazon.com/ecr/)
- [AWS IAM](https://docs.aws.amazon.com/iam/)
- [Makefile](https://www.gnu.org/software/make/manual/make.html)

---

## 🚀 Requirements

- AWS configured account (with ECR and IAM permissions)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [Terraform CLI](https://www.terraform.io/downloads)
- [Docker](https://docs.docker.com/get-docker/)
- GNU Make (`make`)

---

## 📂 Project Structure

```
├── Makefile                 
├── src/
│   ├── app/
│   │   └── index.html       
│   └── terraform/           
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── provider.tf
├── .gitignore
└── README.md
```

---

## ⚙️ Commands

```bash
make help       # Lists every command
```

### 🔧 Build e Deploy

```bash
make build       # Builds locally
make login       # Login into ECR
make tag         # Tags the ECR image
make push        # Sends the image to ECR (login + build + tag)
make deploy      # Sends the image and builds with terraform
```

### 🧹 Clean-up

```bash
make clean       # Cleans up everything
```

---

## ☁️ What is created in AWS?

- An ECR repository for the docker image
- IAM Role for the EC2 to connect with the ECR

---


## 📝 License

This project is licensed by [MIT License](LICENSE).