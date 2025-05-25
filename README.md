# carcierge-staging Architecture on AWS using Terraform

This project implements a carcierge-staging architecture on AWS using Terraform for infrastructure as code and Packer for creating custom AMIs. The architecture follows best practices for high availability, scalability, and security.

## Architecture Overview

The application is deployed across three tiers:

1. **Web Tier (Frontend)**
   - Application Load Balancer (ALB)
   - Auto Scaling Group (ASG)
   - EC2 instances running Nginx
   - Public subnets

2. **Application Tier (Backend)**
   - Internal Application Load Balancer (ALB)
   - Auto Scaling Group (ASG)
   - EC2 instances running PHP/Apache
   - Private subnets

3. **Database Tier**
   - Amazon RDS MySQL instance
   - Private subnets
   - Multi-AZ deployment

## Infrastructure Components

### Network Layer
- VPC with CIDR 10.0.0.0/16
- Public and private subnets across three availability zones
- Internet Gateway for public internet access
- NAT Gateways for private subnet internet access
- Route tables and associations
- Security groups for each tier

### Compute Layer
- Custom AMIs built with Packer
- Auto Scaling Groups for both frontend and backend
- Application Load Balancers
- Launch Templates with user data scripts

### Database Layer
- RDS MySQL instance
- DB subnet group
- Security group for database access

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0
- Packer
- Git
- SSH key pairs for EC2 instances

## Project Structure

```
.
├── packer/
│   ├── frontend/           # Frontend AMI build configuration
│   └── backend/           # Backend AMI build configuration
├── terraform/
│   ├── network/           # VPC, subnets, security groups
│   ├── compute/           # ALBs, ASGs, EC2 instances
│   └── database/          # RDS instance and configuration
├── setup.sh              # Setup script
└── cleanup.sh            # Cleanup script
```

## Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/ajitinamdar-tech/carcierge-staging-architecture-aws-terraform.git
   cd carcierge-staging-architecture-aws-terraform
   ```

2. **Run the setup script**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

The setup script will:
- Create an S3 bucket for Terraform state
- Build custom AMIs using Packer
- Deploy the infrastructure using Terraform
- Configure the application

## Cleanup

To destroy all resources:
```bash
chmod +x cleanup.sh
./cleanup.sh
```

## Security

- Security groups restrict access between tiers
- Private subnets for application and database tiers
- Regular security updates through AMI builds

## Monitoring and Maintenance

- Auto Scaling based on CPU utilization
- Regular AMI updates through Packer builds

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- AWS Documentation
- HashiCorp Terraform Documentation
- HashiCorp Packer Documentation 