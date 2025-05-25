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
check_command aws
check_command jq

# Initialize variables
export AWS_REGION="us-east-1"
export TF_VAR_aws_region=$AWS_REGION

# 1. Clean up EC2 infrastructure
print_section "Destroying EC2 infrastructure"
cd terraform/compute
terraform destroy -auto-approve
cd ../..

# 2. Clean up AMIs
print_section "Cleaning up AMIs"

# Get AMI IDs from the files if they exist
FRONTEND_AMI_ID=""
BACKEND_AMI_ID=""

if [ -f "terraform/compute/ami_ids/frontend_ami.txt" ]; then
    FRONTEND_AMI_ID=$(cat terraform/compute/ami_ids/frontend_ami.txt)
fi

if [ -f "terraform/compute/ami_ids/backend_ami.txt" ]; then
    BACKEND_AMI_ID=$(cat terraform/compute/ami_ids/backend_ami.txt)
fi

# Deregister AMIs if they exist
if [ ! -z "$FRONTEND_AMI_ID" ]; then
    echo "Deregistering Frontend AMI: $FRONTEND_AMI_ID"
    aws ec2 deregister-image --image-id $FRONTEND_AMI_ID
else
    echo "No Frontend AMI ID found, skipping deregistration"
fi

if [ ! -z "$BACKEND_AMI_ID" ]; then
    echo "Deregistering Backend AMI: $BACKEND_AMI_ID"
    aws ec2 deregister-image --image-id $BACKEND_AMI_ID
else
    echo "No Backend AMI ID found, skipping deregistration"
fi

# Clear AMI IDs folder if it exists
if [ -d "terraform/compute/ami_ids" ]; then
    echo "Clearing AMI IDs folder"
    rm -f terraform/compute/ami_ids/*.txt
fi

# 3. Clean up RDS
print_section "Destroying RDS infrastructure"
cd terraform/database
terraform destroy -auto-approve
cd ../..

# 4. Clean up VPC
print_section "Destroying VPC infrastructure"

# Get VPC ID
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=carcierge-staging-app-vpc" --query 'Vpcs[0].VpcId' --output text)

# Now destroy the VPC infrastructure
cd terraform/network
terraform destroy -auto-approve
cd ../..

# 5. Remove local key files and AWS key pairs
print_section "Removing local key files and AWS key pairs"
# Remove local key files
rm -f terraform/compute/keys/frontend.pub terraform/compute/keys/frontend
rm -f terraform/compute/keys/backend.pub terraform/compute/keys/backend

# 6. Clean up S3 bucket
print_section "Cleaning up S3 bucket"
# Check if bucket exists
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "Deleting S3 bucket: $BUCKET_NAME"
    # First, remove all objects in the bucket
    aws s3 rm "s3://$BUCKET_NAME" --recursive || true
    # Then delete the bucket
    aws s3 rb "s3://$BUCKET_NAME" --force || true
else
    echo "S3 bucket $BUCKET_NAME does not exist, skipping deletion"
fi

print_section "Cleanup completed successfully!"