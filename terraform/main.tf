provider "aws" {
  region = var.region
}

resource "aws_key_pair" "dxo_key" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.public_key_path)
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-subnet-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-subnet-b"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# Web Server SG
resource "aws_security_group" "web_sg" {
  name   = "${var.project_name}-web-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow HTTPS from anywhere (LB)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # You can restrict this later
  }

  ingress {
    description = "Allow SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["78.45.154.248/32"] # Replace with your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DB Server SG
resource "aws_security_group" "db_sg" {
  name   = "${var.project_name}-db-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Postgres access from web servers"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Web Server 1
resource "aws_instance" "web1" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_a.id
  key_name                    = aws_key_pair.dxo_key.key_name
  associate_public_ip_address = true
  security_groups             = [aws_security_group.web_sg.id]
  tags = {
    Name = "${var.project_name}-web1"
  }
}

# Web Server 2
resource "aws_instance" "web2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_b.id
  key_name                    = aws_key_pair.dxo_key.key_name
  associate_public_ip_address = true
  security_groups             = [aws_security_group.web_sg.id]
  tags = {
    Name = "${var.project_name}-web2"
  }
}

# PostgreSQL Server
resource "aws_instance" "db" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_a.id
  key_name                    = aws_key_pair.dxo_key.key_name
  associate_public_ip_address = true
  security_groups             = [aws_security_group.db_sg.id]
  tags = {
    Name = "${var.project_name}-db"
  }
}

# ALB SG
resource "aws_security_group" "alb_sg" {
  name   = "${var.project_name}-alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load Balancer
resource "aws_lb" "app_lb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

# Target Group
resource "aws_lb_target_group" "web_tg" {
  name     = "${var.project_name}-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.main.id
  health_check {
    path                = "/"
    protocol            = "HTTPS"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

# Register EC2s in Target Group
resource "aws_lb_target_group_attachment" "web1_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web1.id
  port             = 443
}

resource "aws_lb_target_group_attachment" "web2_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web2.id
  port             = 443
}

# Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.certificate_arn
}


variable "certificate_arn" {
  description = "ACM certificate for domain"
}
