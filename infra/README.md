# Medium-size infrastructure using Terraform

This directory contains code as an example of structuring Terraform configurations for a medium-size infrastructure with several AWS accounts and off-the-shelf infrastructure modules.

## Features

- Cloud Run: Serverless container platform for deploying and scaling containerized applications quickly and securely.
- Cloud Build: Fully managed CI/CD platform that builds, tests, and deploys applications quickly and efficiently.
- Terraform modules: Reusable infrastructure components for Cloud Run and Cloud Build, promoting consistency and maintainability.
- Production environment configuration: Separate directory for production-specific Terraform configurations and variables.

## Structure

```
.
├── modules
│   ├── cloudbuild
│   └── cloudrun
└── prod
    ├── main.tf
    ├── terraform.tfvars
    └── variables.tf
```

## Usage

To use this infrastructure, navigate to either the `prod` or `stage` directory and run:

```
terraform init
terraform plan
terraform apply
```

Make sure you have the correct AWS credentials set up for each environment.
