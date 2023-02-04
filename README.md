# terraform-project  

## set-up project
```bash
# Terraform Project

## Introduction
This Terraform project sets up infrastructure for a multi-tier web application.

## Prerequisites
- Terraform installed on your local machine.
- Access to an AWS account with necessary permissions to create AWS resources.

## Usage
1. Clone this repository to your local machine.
2. Navigate to the directory where the Terraform files are located.
3. Initialize Terraform by running `terraform init`.
4. Verify the Terraform plan by running `terraform plan`.
5. Apply the Terraform plan by running `terraform apply`.

## Terraform Components
- VPC
- Subnets
- Internet Gateway
- subnet association
- Routing Tables
- Security Groups
- EC2 instances
- Load Balancer

## Note
- Update the `variables.tf` file with your AWS access and secret key.
- Update the `terraform.tfvars` file with the desired values for your infrastructure.
- Always run `terraform plan` before running `terraform apply`.

## Conclusion
With this Terraform project, you can easily set up the infrastructure for a multi-tier web application on AWS.


```# 
