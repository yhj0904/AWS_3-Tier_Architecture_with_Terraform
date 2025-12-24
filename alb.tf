# Application Load Balancer 
resource "aws_lb" "nginx_alb" {
  count = var.enable_alb ? 1 : 0

  name               = "yhj09-VEC-PRD-NGINX-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.nginx_sg.id]
  subnets = [
    aws_subnet.yhj09-VEC-PRD-VPC-NGINX-PUB-2A.id,
    aws_subnet.yhj09-VEC-PRD-VPC-NGINX-PUB-2C.id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "yhj09-VEC-PRD-NGINX-ALB"
  }
}

# Target Group for NGINX
resource "aws_lb_target_group" "nginx_tg" {
  count = var.enable_alb ? 1 : 0

  name     = "yhj09-VEC-PRD-NGINX-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.yhj09-VEC-PRD-VPC.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "yhj09-VEC-PRD-NGINX-TG"
  }
}

# Register NGINX instances to Target Group
resource "aws_lb_target_group_attachment" "nginx_2a" {
  count = var.enable_alb ? 1 : 0

  target_group_arn = aws_lb_target_group.nginx_tg[0].arn
  target_id        = aws_instance.nginx_2a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "nginx_2c" {
  count = var.enable_alb ? 1 : 0

  target_group_arn = aws_lb_target_group.nginx_tg[0].arn
  target_id        = aws_instance.nginx_2c.id
  port             = 80
}

# ALB Listener - HTTP (Redirect to HTTPS)
resource "aws_lb_listener" "nginx_http_redirect" {
  count = var.enable_alb && var.enable_http_to_https_redirect && var.enable_https ? 1 : 0

  load_balancer_arn = aws_lb.nginx_alb[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ALB Listener - HTTP (Forward to Target Group)
resource "aws_lb_listener" "nginx_http_forward" {
  count = var.enable_alb && !(var.enable_http_to_https_redirect && var.enable_https) ? 1 : 0

  load_balancer_arn = aws_lb.nginx_alb[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg[0].arn
  }
}

# ALB Listener - HTTPS
resource "aws_lb_listener" "nginx_https" {
  count = var.enable_alb && var.enable_https && var.acm_certificate_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.nginx_alb[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg[0].arn
  }
}