#!/bin/bash

set -e  # Exit on any error

# Function to print section headers
print_section() {
    echo "================================================"
    echo " $1"
    echo "================================================"
}

# Function to check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "Error: $1 is required but not installed."
        exit 1
    fi
}

# Check required tools
check_command terraform
check_command packer
check_command aws
check_command jq

# Initialize variables
export AWS_REGION="us-west-2"
export TF_VAR_aws_region=$AWS_REGION

# Create S3 bucket for Terraform state if it doesn't exist
print_section "Setting up Terraform state bucket"
BUCKET_NAME="three-tier-arch-aws-terraform"
if ! aws s3api head-bucket --bucket $BUCKET_NAME 2>/dev/null; then
    echo "Creating S3 bucket for Terraform state..."
    if [ "$AWS_REGION" = "us-west-2" ]; then
        # us-east-1 doesn't support LocationConstraint
        aws s3api create-bucket \
            --bucket $BUCKET_NAME \
            --region $AWS_REGION
    else
        aws s3api create-bucket \
            --bucket $BUCKET_NAME \
            --region $AWS_REGION \
            --create-bucket-configuration LocationConstraint=$AWS_REGION
    fi
    aws s3api put-bucket-versioning \
        --bucket $BUCKET_NAME \
        --versioning-configuration Status=Enabled
fi

# 1. Create VPC
print_section "Creating VPC infrastructure"
cd terraform/network
terraform init
terraform apply -auto-approve
cd ../..

# 2. Create RDS
print_section "Creating RDS infrastructure"
cd terraform/database
terraform init
terraform apply -auto-approve
cd ../..

# 4. Create AMIs
print_section "Creating AMIs"

# Function to check if AMI exists and is available
check_ami_exists() {
    local ami_id=$1
    if [ ! -z "$ami_id" ]; then
        # Check if AMI exists and is available
        aws ec2 describe-images --image-ids $ami_id --query 'Images[0].State' --output text 2>/dev/null | grep -q "available"
        return $?
    fi
    return 1
}

# 4.1 Create Frontend AMI
print_section "Creating Frontend AMI"
FRONTEND_AMI_ID=""
if [ -f "terraform/compute/ami_ids/frontend_ami.txt" ]; then
    FRONTEND_AMI_ID=$(cat terraform/compute/ami_ids/frontend_ami.txt)
fi

if check_ami_exists "$FRONTEND_AMI_ID"; then
    echo "Frontend AMI $FRONTEND_AMI_ID already exists and is available"
else
    echo "Creating new Frontend AMI..."
    cd packer/frontend
    ./build_ami.sh
    cd ../..
fi

# 4.2 Create Backend AMI
print_section "Creating Backend AMI"
BACKEND_AMI_ID=""
if [ -f "terraform/compute/ami_ids/backend_ami.txt" ]; then
    BACKEND_AMI_ID=$(cat terraform/compute/ami_ids/backend_ami.txt)
fi

if check_ami_exists "$BACKEND_AMI_ID"; then
    echo "Backend AMI $BACKEND_AMI_ID already exists and is available"
else
    echo "Creating new Backend AMI..."
    cd packer/backend
    ./build_ami.sh
    cd ../..
fi

# 4.3 Generate SSH keys
print_section "Generating SSH keys"
cd terraform/compute/keys

# Function to check if local key files exist
check_local_keys() {
    local key_name=$1
    [ -f "$key_name" ] && [ -f "$key_name.pub" ]
    return $?
}

# Generate frontend key pair if it doesn't exist
if ! check_local_keys "frontend"; then
    echo "Creating frontend key pair..."
    ssh-keygen -t rsa -b 4096 -f frontend -N ""
else
    echo "Frontend key pair already exists locally"
fi

# Generate backend key pair if it doesn't exist
if ! check_local_keys "backend"; then
    echo "Creating backend key pair..."
    ssh-keygen -t rsa -b 4096 -f backend -N ""
else
    echo "Backend key pair already exists locally"
fi

echo "SSH key pairs setup completed"
cd ../../..

# 5. Create EC2 infrastructure
print_section "Creating EC2 infrastructure"
cd terraform/compute
terraform init
terraform apply -auto-approve
cd ../..

print_section "Infrastructure setup completed successfully!"
echo "You can now access your application at the ALB DNS name shown in the compute outputs."

