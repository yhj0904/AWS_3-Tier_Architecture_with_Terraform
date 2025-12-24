# ==========================================
# Global Variables
# ==========================================

variable "project_name" {
  type        = string
  default     = "yhj09-VEC-PRD"
  description = "Project name to be used as a prefix for all resources"
}

variable "environment" {
  type        = string
  default     = "production"
  description = "Environment name (production, staging, development)"
  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "Environment must be production, staging, or development."
  }
}

variable "account" {
  type        = string
  default     = "kakaoTest"
  description = "AWS account profile name for CLI authentication"
}

variable "region" {
  type        = string
  default     = "us-east-2"
  description = "AWS region where resources will be created"
  validation {
    condition     = can(regex("^(us|eu|ap|sa|ca|me|af)-(north|south|east|west|central|northeast|southeast)-[1-9]$", var.region))
    error_message = "Region must be a valid AWS region identifier."
  }
}

variable "common_tags" {
  type = map(string)
  default = {
    Project     = "yhj09-VEC-PRD"
    ManagedBy   = "Terraform"
    Owner       = "awsuserid09"
    Environment = "Development"
  }
  description = "Common tags to be applied to all resources"
}

# ==========================================
# VPC Configuration
# ==========================================

variable "vpc_cidr" {
  type        = string
  default     = "10.250.0.0/16"
  description = "CIDR block for VPC"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "Enable DNS hostnames in the VPC"
}

variable "enable_dns_support" {
  type        = bool
  default     = true
  description = "Enable DNS support in the VPC"
}

variable "instance_tenancy" {
  type        = string
  default     = "default"
  description = "A tenancy option for instances launched into the VPC (default, dedicated, host)"
  validation {
    condition     = contains(["default", "dedicated", "host"], var.instance_tenancy)
    error_message = "Instance tenancy must be default, dedicated, or host."
  }
}

# ==========================================
# Availability Zones
# ==========================================

variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-2a", "us-east-2c"]
  description = "List of availability zones to use for resource distribution"
}

variable "az_short_names" {
  type        = list(string)
  default     = ["2a", "2c"]
  description = "Short names for availability zones (for resource naming)"
}

# ==========================================
# Subnet Configuration
# ==========================================
# NOTE: These subnet variables are defined but NOT USED.
# Actual subnet configurations are hardcoded in vpc.tf
# TODO: Consider removing these unused variables or refactoring vpc.tf to use them

variable "public_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    name_suffix       = string
  }))
  default = {
    nginx_pub_2a = {
      cidr_block        = "10.250.1.0/24"
      availability_zone = "us-east-2a"
      name_suffix       = "NGINX-PUB-2A"
    }
    nginx_pub_2c = {
      cidr_block        = "10.250.11.0/24"
      availability_zone = "us-east-2c"
      name_suffix       = "NGINX-PUB-2C"
    }
  }
  description = "Public subnet configurations"
}

variable "private_app_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    name_suffix       = string
  }))
  default = {
    tomcat_pri_2a = {
      cidr_block        = "10.250.2.0/24"
      availability_zone = "us-east-2a"
      name_suffix       = "TOMCAT-PRI-2A"
    }
    tomcat_pri_2c = {
      cidr_block        = "10.250.12.0/24"
      availability_zone = "us-east-2c"
      name_suffix       = "TOMCAT-PRI-2C"
    }
  }
  description = "Private application subnet configurations"
}

variable "private_db_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    name_suffix       = string
  }))
  default = {
    db_pri_2a = {
      cidr_block        = "10.250.13.0/24"
      availability_zone = "us-east-2a"
      name_suffix       = "DB-PRI-2A"
    }
    db_pri_2c = {
      cidr_block        = "10.250.12.0/24"
      availability_zone = "us-east-2c"
      name_suffix       = "DB-PRI-2C"
    }
    # REMOVED: dbpri_2a - duplicate DB subnet definition
  }
  description = "Private database subnet configurations"
}

# ==========================================
# EC2 Instance Configuration
# ==========================================

variable "nginx_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type for NGINX web servers"
  validation {
    condition     = can(regex("^t[2-3]\\.(nano|micro|small|medium|large|xlarge|2xlarge)$", var.nginx_instance_type))
    error_message = "NGINX instance type must be a valid t2 or t3 instance type."
  }
}

variable "tomcat_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type for Tomcat application servers"
  validation {
    condition     = can(regex("^t[2-3]\\.(nano|micro|small|medium|large|xlarge|2xlarge)$", var.tomcat_instance_type))
    error_message = "Tomcat instance type must be a valid t2 or t3 instance type."
  }
}

variable "bastion_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Instance type for Bastion Host"
  validation {
    condition     = can(regex("^t[2-3]\\.(nano|micro|small|medium)$", var.bastion_instance_type))
    error_message = "Bastion instance type must be a valid t2 or t3 small instance type."
  }
}

variable "enable_bastion" {
  type        = bool
  default     = true
  description = "Enable Bastion Host for SSH access to private instances"
}

variable "enable_detailed_monitoring" {
  type        = bool
  default     = false
  description = "Enable detailed monitoring for EC2 instances (additional cost)"
}

variable "root_volume_size" {
  type        = number
  default     = 20
  description = "Size of root volume in GB for EC2 instances"
  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 1000
    error_message = "Root volume size must be between 8 and 1000 GB."
  }
}

variable "root_volume_type" {
  type        = string
  default     = "gp3"
  description = "Type of root volume (gp2, gp3, io1, io2)"
  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.root_volume_type)
    error_message = "Root volume type must be gp2, gp3, io1, or io2."
  }
}

# ==========================================
# SSH Key Configuration
# ==========================================

variable "key_pair_algorithm" {
  type        = string
  default     = "RSA"
  description = "Algorithm for SSH key pair (RSA, ECDSA, ED25519)"
  validation {
    condition     = contains(["RSA", "ECDSA", "ED25519"], var.key_pair_algorithm)
    error_message = "Key pair algorithm must be RSA, ECDSA, or ED25519."
  }
}

variable "key_pair_rsa_bits" {
  type        = number
  default     = 4096
  description = "Number of bits for RSA key pair (2048, 4096)"
  validation {
    condition     = contains([2048, 4096], var.key_pair_rsa_bits)
    error_message = "RSA bits must be 2048 or 4096."
  }
}

# ==========================================
# RDS Database Configuration
# ==========================================

variable "db_engine" {
  type        = string
  default     = "mysql"
  description = "Database engine (mysql, postgres, mariadb)"
  validation {
    condition     = contains(["mysql", "postgres", "mariadb"], var.db_engine)
    error_message = "Database engine must be mysql, postgres, or mariadb."
  }
}

variable "db_engine_version" {
  type        = string
  default     = "8.0"
  description = "Database engine version"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "RDS instance class"
  validation {
    condition     = can(regex("^db\\.(t[2-3]|m[4-6]|r[4-6])\\.(micro|small|medium|large|xlarge|2xlarge|4xlarge|8xlarge)$", var.db_instance_class))
    error_message = "DB instance class must be a valid RDS instance type."
  }
}

variable "db_allocated_storage" {
  type        = number
  default     = 20
  description = "Allocated storage for RDS in GB"
  validation {
    condition     = var.db_allocated_storage >= 20 && var.db_allocated_storage <= 65536
    error_message = "DB allocated storage must be between 20 and 65536 GB."
  }
}

variable "db_storage_type" {
  type        = string
  default     = "gp3"
  description = "Storage type for RDS (gp2, gp3, io1)"
  validation {
    condition     = contains(["gp2", "gp3", "io1"], var.db_storage_type)
    error_message = "DB storage type must be gp2, gp3, or io1."
  }
}

variable "db_name" {
  type        = string
  default     = "appdb"
  description = "Initial database name"
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_name))
    error_message = "Database name must start with a letter and contain only alphanumeric characters and underscores."
  }
}

variable "db_username" {
  type        = string
  default     = "admin"
  description = "Master username for database"
  validation {
    condition     = length(var.db_username) >= 1 && length(var.db_username) <= 16
    error_message = "Database username must be between 1 and 16 characters."
  }
}

variable "db_password" {
  type        = string
  default     = "YourStrongPassword123!"
  description = "Master password for database (use AWS Secrets Manager in production)"
  sensitive   = true
  validation {
    condition     = length(var.db_password) >= 8
    error_message = "Database password must be at least 8 characters long."
  }
}

variable "db_multi_az" {
  type        = bool
  default     = true
  description = "Enable Multi-AZ deployment for RDS"
}

variable "db_backup_retention_period" {
  type        = number
  default     = 7
  description = "Number of days to retain automated backups (0-35)"
  validation {
    condition     = var.db_backup_retention_period >= 0 && var.db_backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "db_backup_window" {
  type        = string
  default     = "03:00-04:00"
  description = "Preferred backup window (UTC)"
}

variable "db_maintenance_window" {
  type        = string
  default     = "mon:04:00-mon:05:00"
  description = "Preferred maintenance window (UTC)"
}

variable "db_storage_encrypted" {
  type        = bool
  default     = true
  description = "Enable storage encryption for RDS"
}

variable "db_skip_final_snapshot" {
  type        = bool
  default     = false
  description = "Skip final snapshot when destroying RDS (set to true for dev/test)"
}

variable "db_deletion_protection" {
  type        = bool
  default     = true
  description = "Enable deletion protection for RDS"
}

# ==========================================
# Load Balancer Configuration
# ==========================================

variable "alb_deletion_protection" {
  type        = bool
  default     = false
  description = "Enable deletion protection for Application Load Balancers"
}

variable "alb_idle_timeout" {
  type        = number
  default     = 60
  description = "The time in seconds that the connection is allowed to be idle"
  validation {
    condition     = var.alb_idle_timeout >= 1 && var.alb_idle_timeout <= 4000
    error_message = "ALB idle timeout must be between 1 and 4000 seconds."
  }
}

variable "target_group_health_check_interval" {
  type        = number
  default     = 30
  description = "Health check interval in seconds"
  validation {
    condition     = var.target_group_health_check_interval >= 5 && var.target_group_health_check_interval <= 300
    error_message = "Health check interval must be between 5 and 300 seconds."
  }
}

variable "target_group_health_check_timeout" {
  type        = number
  default     = 5
  description = "Health check timeout in seconds"
  validation {
    condition     = var.target_group_health_check_timeout >= 2 && var.target_group_health_check_timeout <= 120
    error_message = "Health check timeout must be between 2 and 120 seconds."
  }
}

variable "target_group_healthy_threshold" {
  type        = number
  default     = 2
  description = "Number of consecutive health checks successes required"
  validation {
    condition     = var.target_group_healthy_threshold >= 2 && var.target_group_healthy_threshold <= 10
    error_message = "Healthy threshold must be between 2 and 10."
  }
}

variable "target_group_unhealthy_threshold" {
  type        = number
  default     = 2
  description = "Number of consecutive health check failures required"
  validation {
    condition     = var.target_group_unhealthy_threshold >= 2 && var.target_group_unhealthy_threshold <= 10
    error_message = "Unhealthy threshold must be between 2 and 10."
  }
}

# ==========================================
# NAT Gateway Configuration
# ==========================================

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Enable NAT Gateway for private subnets"
}

variable "single_nat_gateway" {
  type        = bool
  default     = true
  description = "Use a single NAT Gateway for all private subnets (cost optimization)"
}

# ==========================================
# Security Group Configuration
# ==========================================

variable "allowed_ssh_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR blocks allowed to SSH into instances (restrict in production)"
}

variable "allowed_http_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR blocks allowed to access HTTP/HTTPS"
}

# ==========================================
# Application Configuration
# ==========================================

variable "tomcat_version" {
  type        = string
  default     = "9.0.96"
  description = "Tomcat version to install"
}

variable "nginx_version" {
  type        = string
  default     = "latest"
  description = "NGINX version to install (latest or specific version)"
}

# ==========================================
# Cost Optimization Tags
# ==========================================

variable "cost_center" {
  type        = string
  default     = "Engineering"
  description = "Cost center for billing allocation"
}

variable "auto_shutdown" {
  type        = bool
  default     = false
  description = "Enable automatic shutdown for non-production environments"
}

variable "backup_enabled" {
  type        = bool
  default     = true
  description = "Enable automated backups"
}

# ==========================================
# SSL/TLS Certificate Configuration
# ==========================================

variable "acm_certificate_arn" {
  type        = string
  default     = ""
  description = "ARN of ACM certificate for HTTPS listener. Leave empty to skip HTTPS configuration."
}

variable "enable_https" {
  type        = bool
  default     = false
  description = "Enable HTTPS listener on ALB (requires ACM certificate)"
}

variable "enable_http_to_https_redirect" {
  type        = bool
  default     = false
  description = "Redirect HTTP traffic to HTTPS (only works when HTTPS is enabled)"
}

# ==========================================
# Route 53 DNS Configuration
# ==========================================

variable "enable_route53" {
  type        = bool
  default     = true
  description = "Enable Route 53 DNS management"
}

variable "enable_alb" {
  type        = bool
  default     = false
  description = "Enable Application Load Balancer (set to false to use direct IP)"
}

variable "domain_name" {
  type        = string
  default     = "popori.store"
  description = "Domain name for Route 53 (e.g., popori.store)"
  validation {
    condition     = var.domain_name == "" || can(regex("^[a-z0-9][a-z0-9-]*\\.[a-z]{2,}$", var.domain_name))
    error_message = "Domain name must be a valid domain (e.g., example.com)"
  }
}

variable "enable_www_subdomain" {
  type        = bool
  default     = true
  description = "Enable www subdomain (www.domain.com)"
}
