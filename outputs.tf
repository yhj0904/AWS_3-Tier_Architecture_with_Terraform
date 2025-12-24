# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.yhj09-VEC-PRD-VPC.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.yhj09-VEC-PRD-VPC.cidr_block
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = [
    aws_subnet.yhj09-VEC-PRD-VPC-NGINX-PUB-2A.id,
    aws_subnet.yhj09-VEC-PRD-VPC-NGINX-PUB-2C.id
  ]
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value = [
    aws_subnet.yhj09-VEC-PRD-VPC-TOMCAT-PRI-2A.id,
    aws_subnet.yhj09-VEC-PRD-VPC-TOMCAT-PRI-2C.id,
    aws_subnet.yhj09-VEC-PRD-VPC-DB-PRI-2A.id,
    aws_subnet.yhj09-VEC-PRD-VPC-DB-PRI-2C.id
  ]
}

# EC2 Outputs
output "nginx_instance_ids" {
  description = "NGINX instance IDs"
  value = [
    aws_instance.nginx_2a.id,
    aws_instance.nginx_2c.id
  ]
}

output "nginx_public_ips" {
  description = "NGINX public IPs"
  value = [
    aws_instance.nginx_2a.public_ip,
    aws_instance.nginx_2c.public_ip
  ]
}

output "tomcat_instance_ids" {
  description = "Tomcat instance IDs"
  value = [
    aws_instance.tomcat_2a.id,
    aws_instance.tomcat_2c.id
  ]
}

output "tomcat_private_ips" {
  description = "Tomcat private IPs"
  value = [
    aws_instance.tomcat_2a.private_ip,
    aws_instance.tomcat_2c.private_ip
  ]
}

# Load Balancer Outputs
output "nginx_alb_dns" {
  description = "NGINX ALB DNS name"
  value       = var.enable_alb ? aws_lb.nginx_alb[0].dns_name : "ALB not enabled - using direct IP"
}

# Tomcat ALB removed - NGINX now handles load balancing directly
# output "tomcat_alb_dns" {
#   description = "Tomcat ALB DNS name"
#   value       = aws_lb.tomcat_alb.dns_name
# }

# RDS Outputs
output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.mysql_db.endpoint
}

output "rds_arn" {
  description = "RDS ARN"
  value       = aws_db_instance.mysql_db.arn
}

# NAT Gateway Outputs
output "nat_gateway_2a_ip" {
  description = "NAT Gateway 2a public IP"
  value       = aws_eip.nat_eip_2a.public_ip
}

output "nat_gateway_2c_ip" {
  description = "NAT Gateway 2c public IP"
  value       = aws_eip.nat_eip_2c.public_ip
}

output "nat_gateway_2a_id" {
  description = "NAT Gateway 2a ID"
  value       = aws_nat_gateway.nat_gw_2a.id
}

output "nat_gateway_2c_id" {
  description = "NAT Gateway 2c ID"
  value       = aws_nat_gateway.nat_gw_2c.id
}

# Key Pair Output
output "key_pair_name" {
  description = "SSH key pair name"
  value       = aws_key_pair.key_pair.key_name
}

output "private_key_location" {
  description = "Private key file location"
  value       = "${aws_key_pair.key_pair.key_name}.pem"
}

# Bastion Host Outputs
output "bastion_public_ip" {
  description = "Public IP address of Bastion Host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_instance_id" {
  description = "Instance ID of Bastion Host"
  value       = aws_instance.bastion.id
}

output "bastion_ssh_command" {
  description = "SSH command to connect to Bastion Host"
  value       = "ssh -i ${aws_key_pair.key_pair.key_name}.pem ec2-user@${aws_instance.bastion.public_ip}"
}

# HTTPS Configuration Outputs
output "https_enabled" {
  description = "Whether HTTPS is enabled on the ALB"
  value       = var.enable_https
}

output "alb_https_url" {
  description = "HTTPS URL for the NGINX ALB (if HTTPS is enabled)"
  value       = var.enable_alb && var.enable_https ? "https://${aws_lb.nginx_alb[0].dns_name}" : "ALB or HTTPS not enabled"
}

# Route 53 Outputs
output "route53_nameservers" {
  description = "Route 53 name servers (configure these in your domain registrar)"
  value       = var.enable_route53 ? aws_route53_zone.main[0].name_servers : []
}

output "domain_url" {
  description = "Primary domain URL"
  value       = var.enable_route53 && var.enable_https ? "https://${var.domain_name}" : (var.enable_route53 ? "http://${var.domain_name}" : "Route 53 not enabled")
}

output "www_domain_url" {
  description = "WWW subdomain URL"
  value       = var.enable_route53 && var.enable_www_subdomain && var.enable_https ? "https://www.${var.domain_name}" : (var.enable_route53 && var.enable_www_subdomain ? "http://www.${var.domain_name}" : "WWW subdomain not enabled")
}
