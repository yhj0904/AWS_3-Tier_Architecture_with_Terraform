# Route 53 Hosted Zone
resource "aws_route53_zone" "main" {
  count = var.enable_route53 ? 1 : 0

  name = var.domain_name

  tags = {
    Name = "${var.project_name}-Hosted-Zone"
  }
}

# A Record for ALB (Recommended)
resource "aws_route53_record" "alb" {
  count = var.enable_route53 && var.enable_alb ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.nginx_alb[0].dns_name
    zone_id                = aws_lb.nginx_alb[0].zone_id
    evaluate_target_health = true
  }
}

# A Record for Direct IP (Fallback) - Only used when ALB is disabled
resource "aws_route53_record" "nginx_direct_ip" {
  count = var.enable_route53 && !var.enable_alb ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 300

  records = [aws_instance.nginx_2a.public_ip]
}

# WWW subdomain with ALB
resource "aws_route53_record" "www_alb" {
  count = var.enable_route53 && var.enable_www_subdomain && var.enable_alb ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.nginx_alb[0].dns_name
    zone_id                = aws_lb.nginx_alb[0].zone_id
    evaluate_target_health = true
  }
}

# WWW subdomain with Direct IP (Fallback) - Only used when ALB is disabled
resource "aws_route53_record" "www_direct_ip" {
  count = var.enable_route53 && var.enable_www_subdomain && !var.enable_alb ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = "www.${var.domain_name}"
  type    = "A"
  ttl     = 300

  records = [aws_instance.nginx_2a.public_ip]
}
