# EC2-Nginx-Deployment-with-Terraform

Deploy an Ubuntu 20.04 EC2 running Nginx (custom index.html) using Terraform.
This repo contains a minimal, assignment-friendly Terraform configuration that launches a t2.micro instance in the default VPC, opens HTTP (80) and SSH (22), provisions Nginx via user_data, replaces the index page with:

Welcome to the Terraform-managed Nginx Server on Ubuntu

Project structure

terraform-nginx-ubuntu/
├── main.tf         # Terraform configuration (provider, data, SG, EC2)
├── variables.tf    # Variables (region, instance type, key_name, environment)
├── outputs.tf      # Outputs (instance public IP / DNS)
├── README.md       
└── images/        

Quick prerequisites
Terraform CLI >= 1.0 installed and on PATH.

An AWS account with a default VPC in the region you plan to use (most accounts have this).

AWS credentials available locally (via environment variables or ~/.aws/credentials):

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

AWS_DEFAULT_REGION (or pass -var="aws_region=..." to terraform)

How to run (step-by-step)
Open a terminal in the project folder.

1. Set AWS credentials using aws configure

2. Initialize Terraform

terraform init

3. (Optional) Format and validate

terraform fmt
terraform validate

4. Plan
Explicitly pass the region if you didn't set AWS_DEFAULT_REGION env var:

terraform plan -var="aws_region=ap-south-1"

5. Apply
Interactive (recommended first time):

terraform apply -var="aws_region=ap-south-1"

Non-interactive:

terraform apply -var="aws_region=ap-south-1" -auto-approve
When apply finishes, Terraform will show outputs including instance_public_ip.

6. Verify Nginx is working
From your machine:

# Get raw output (single string)
terraform output -raw instance_public_ip

# Curl the public IP
curl http://$(terraform output -raw instance_public_ip)
# or open http://<public-ip> in your browser
You should see the HTML that contains:
Welcome to the Terraform-managed Nginx Server on Ubuntu

Tear down (required by assignment)
To remove resources:

terraform destroy -var="aws_region=ap-south-1"

# or

terraform destroy -var="aws_region=ap-south-1" -auto-approve
Confirm in AWS Console that the instance and security group are gone (or run aws ec2 describe-instances with filters).
