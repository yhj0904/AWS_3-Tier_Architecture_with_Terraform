# NGINX Instances (Public Subnet)
resource "aws_instance" "nginx_2a" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.yhj09-VEC-PRD-VPC-NGINX-PUB-2A.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  key_name               = aws_key_pair.key_pair.key_name

  # IMDSv2 enforcement for enhanced security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install nginx1 -y

              # Create web root directory and sample HTML
              mkdir -p /var/www/html
              cat > /var/www/html/index.html <<'HTML'
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Welcome to popori.store</title>
                  <style>
                      body { font-family: Arial; text-align: center; padding: 50px; }
                      h1 { color: #333; }
                      .links { margin-top: 30px; }
                      a { margin: 0 15px; }
                  </style>
              </head>
              <body>
                  <h1>Welcome to popori.store</h1>
                  <p>This is the NGINX static page</p>
                  <div class="links">
                      <a href="/app">Go to Application</a>
                      <a href="/api">API Endpoint</a>
                  </div>
              </body>
              </html>
              HTML
              chown -R nginx:nginx /var/www/html

              # Configure NGINX reverse proxy with AZ-based routing
              cat > /etc/nginx/conf.d/tomcat.conf <<'NGINXCONF'
              upstream tomcat_backend {
                  # Primary: Tomcat 2A (same AZ) - Using private DNS
                  server ${aws_instance.tomcat_2a.private_dns}:8080 max_fails=3 fail_timeout=30s;

                  # Backup: Tomcat 2C (cross-AZ) - Using private DNS
                  server ${aws_instance.tomcat_2c.private_dns}:8080 backup;
              }

              server {
                  listen 80;
                  server_name popori.store www.popori.store;
                  root /var/www/html;
                  index index.html index.htm;

                  # Serve static files from NGINX
                  location / {
                      try_files $uri $uri/ /index.html;
                  }

                  # Proxy dynamic content to Tomcat
                  location /app {
                      proxy_pass http://tomcat_backend/;
                      proxy_set_header Host $host;
                      proxy_set_header X-Real-IP $remote_addr;
                      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                      proxy_set_header X-Forwarded-Proto $scheme;

                      # Connection settings
                      proxy_connect_timeout 60s;
                      proxy_send_timeout 60s;
                      proxy_read_timeout 60s;
                  }

                  # API requests to Tomcat
                  location /api {
                      proxy_pass http://tomcat_backend/api;
                      proxy_set_header Host $host;
                      proxy_set_header X-Real-IP $remote_addr;
                      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                      proxy_set_header X-Forwarded-Proto $scheme;
                  }

                  location /health {
                      access_log off;
                      return 200 "healthy\n";
                      add_header Content-Type text/plain;
                  }
              }
              NGINXCONF

              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "yhj09-VEC-PRD-NGINX-2A"
  }
}

resource "aws_instance" "nginx_2c" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.yhj09-VEC-PRD-VPC-NGINX-PUB-2C.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  key_name               = aws_key_pair.key_pair.key_name

  # IMDSv2 enforcement for enhanced security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install nginx1 -y

              # Create web root directory and sample HTML
              mkdir -p /var/www/html
              cat > /var/www/html/index.html <<'HTML'
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Welcome to popori.store</title>
                  <style>
                      body { font-family: Arial; text-align: center; padding: 50px; }
                      h1 { color: #333; }
                      .links { margin-top: 30px; }
                      a { margin: 0 15px; }
                  </style>
              </head>
              <body>
                  <h1>Welcome to popori.store</h1>
                  <p>This is the NGINX static page</p>
                  <div class="links">
                      <a href="/app">Go to Application</a>
                      <a href="/api">API Endpoint</a>
                  </div>
              </body>
              </html>
              HTML
              chown -R nginx:nginx /var/www/html

              # Configure NGINX reverse proxy with AZ-based routing
              cat > /etc/nginx/conf.d/tomcat.conf <<'NGINXCONF'
              upstream tomcat_backend {
                  # Primary: Tomcat 2C (same AZ) - Using private DNS
                  server ${aws_instance.tomcat_2c.private_dns}:8080 max_fails=3 fail_timeout=30s;

                  # Backup: Tomcat 2A (cross-AZ) - Using private DNS
                  server ${aws_instance.tomcat_2a.private_dns}:8080 backup;
              }

              server {
                  listen 80;
                  server_name popori.store www.popori.store;
                  root /var/www/html;
                  index index.html index.htm;

                  # Serve static files from NGINX
                  location / {
                      try_files $uri $uri/ /index.html;
                  }

                  # Proxy dynamic content to Tomcat
                  location /app {
                      proxy_pass http://tomcat_backend/;
                      proxy_set_header Host $host;
                      proxy_set_header X-Real-IP $remote_addr;
                      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                      proxy_set_header X-Forwarded-Proto $scheme;

                      # Connection settings
                      proxy_connect_timeout 60s;
                      proxy_send_timeout 60s;
                      proxy_read_timeout 60s;
                  }

                  # API requests to Tomcat
                  location /api {
                      proxy_pass http://tomcat_backend/api;
                      proxy_set_header Host $host;
                      proxy_set_header X-Real-IP $remote_addr;
                      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                      proxy_set_header X-Forwarded-Proto $scheme;
                  }

                  location /health {
                      access_log off;
                      return 200 "healthy\n";
                      add_header Content-Type text/plain;
                  }
              }
              NGINXCONF

              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "yhj09-VEC-PRD-NGINX-2C"
  }
}

# Bastion Host Instance (Public Subnet)
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.yhj09-VEC-PRD-VPC-NGINX-PUB-2A.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = aws_key_pair.key_pair.key_name

  # IMDSv2 enforcement for enhanced security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y telnet nc
              EOF

  tags = {
    Name = "yhj09-VEC-PRD-BASTION"
  }
}

# Tomcat Instances (Private Subnet)
resource "aws_instance" "tomcat_2a" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.yhj09-VEC-PRD-VPC-TOMCAT-PRI-2A.id
  vpc_security_group_ids = [aws_security_group.tomcat_sg.id]
  key_name               = aws_key_pair.key_pair.key_name

  # IMDSv2 enforcement for enhanced security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y java-11-amazon-corretto wget

              # Install Tomcat
              cd /opt
              wget -q https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.113/bin/apache-tomcat-9.0.113.tar.gz
              tar -xzf apache-tomcat-9.0.113.tar.gz
              mv apache-tomcat-9.0.113 tomcat
              rm -f apache-tomcat-9.0.113.tar.gz

              # Create tomcat user
              useradd -r -m -U -d /opt/tomcat -s /bin/false tomcat
              chown -R tomcat:tomcat /opt/tomcat

              # Create systemd service
              cat > /etc/systemd/system/tomcat.service <<'SERVICE'
              [Unit]
              Description=Apache Tomcat Web Application Container
              After=network.target

              [Service]
              Type=forking
              User=tomcat
              Group=tomcat
              Environment="JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto"
              Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
              Environment="CATALINA_HOME=/opt/tomcat"
              Environment="CATALINA_BASE=/opt/tomcat"
              ExecStart=/opt/tomcat/bin/startup.sh
              ExecStop=/opt/tomcat/bin/shutdown.sh
              Restart=on-failure

              [Install]
              WantedBy=multi-user.target
              SERVICE

              # Start Tomcat
              systemctl daemon-reload
              systemctl start tomcat
              systemctl enable tomcat
              EOF

  tags = {
    Name = "yhj09-VEC-PRD-TOMCAT-2A"
  }
}

resource "aws_instance" "tomcat_2c" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.yhj09-VEC-PRD-VPC-TOMCAT-PRI-2C.id
  vpc_security_group_ids = [aws_security_group.tomcat_sg.id]
  key_name               = aws_key_pair.key_pair.key_name

  # IMDSv2 enforcement for enhanced security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y java-11-amazon-corretto wget

              # Install Tomcat
              cd /opt
              wget -q https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.113/bin/apache-tomcat-9.0.113.tar.gz
              tar -xzf apache-tomcat-9.0.113.tar.gz
              mv apache-tomcat-9.0.113 tomcat
              rm -f apache-tomcat-9.0.113.tar.gz

              # Create tomcat user
              useradd -r -m -U -d /opt/tomcat -s /bin/false tomcat
              chown -R tomcat:tomcat /opt/tomcat

              # Create systemd service
              cat > /etc/systemd/system/tomcat.service <<'SERVICE'
              [Unit]
              Description=Apache Tomcat Web Application Container
              After=network.target

              [Service]
              Type=forking
              User=tomcat
              Group=tomcat
              Environment="JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto"
              Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
              Environment="CATALINA_HOME=/opt/tomcat"
              Environment="CATALINA_BASE=/opt/tomcat"
              ExecStart=/opt/tomcat/bin/startup.sh
              ExecStop=/opt/tomcat/bin/shutdown.sh
              Restart=on-failure

              [Install]
              WantedBy=multi-user.target
              SERVICE

              # Start Tomcat
              systemctl daemon-reload
              systemctl start tomcat
              systemctl enable tomcat
              EOF

  tags = {
    Name = "yhj09-VEC-PRD-TOMCAT-2C"
  }
}
