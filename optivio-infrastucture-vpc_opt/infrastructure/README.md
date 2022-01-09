# Optivio-Terraform-Project

The goal of the vpc folder is to create 
One VPC
Two Private Subnets
Two Public Subnets
Nat-Gateway, RouteTables and Internet-gateway 
EIP
Security Groups 
EC2 instance (Bastion host)

Step1: Acquire access to AWSCLI and permission to Provision VPC and EC2 on AWS
Step2: Clone this repo
Step3: Run terraform init for initialization 
Step4: Depending on the project environment. There are three env setup variables dev, prod, test
       Run "terraform plan" based on the environment to change use specific variables at runtime as shown below
       RUN: terraform plan --var-file=variables/dev.tfvars --auto-approve
Step5: Examine resources to be created and run "terraform apply" with the environment variables as shown below
       terraform apply --var-file=variables/dev.tfvars --auto-approve

With the output file initialized and applied, all cidr-blocks should be displayed for vpc and 4subnets
