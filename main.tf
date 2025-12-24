# Main Terraform configuration for AWS 3-Tier Web Application
#
# This infrastructure includes:
# - VPC with public and private subnets across 2 availability zones
# - NGINX web servers in public subnets with ALB
# - Tomcat application servers in private subnets with internal ALB
# - RDS MySQL database in private subnets (Multi-AZ)
# - NAT Gateway for private subnet internet access
# - Security groups for each layer
# - SSH key pair for instance access
#
# Provider configuration is in provider.tf
# Network resources are split across vpc.tf, nat-gateway.tf, security-groups.tf
# Compute resources are in ec2-instances.tf
# Load balancers are in alb.tf
# Database is in rds.tf
