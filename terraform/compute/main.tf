# Frontend Application Load Balancer
resource "aws_lb" "frontend" {
  name               = "${var.project_name}-frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.terraform_remote_state.network.outputs.frontend_alb_sg_id]
  subnets            = data.terraform_remote_state.network.outputs.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name        = "${var.project_name}-frontend-alb"
    Environment = var.environment
  }
}

# Frontend Target Group
resource "aws_lb_target_group" "frontend" {
  name     = "${var.project_name}-frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher            = "200"
    path               = "/"
    port               = "traffic-port"
    protocol           = "HTTP"
    timeout            = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.project_name}-frontend-tg"
    Environment = var.environment
  }
}

# Frontend Listener
resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# Frontend Auto Scaling Group
resource "aws_autoscaling_group" "frontend" {
  name                = "${var.project_name}-frontend-asg"
  vpc_zone_identifier = data.terraform_remote_state.network.outputs.web_private_subnet_ids
  desired_capacity    = var.frontend_desired_capacity
  max_size           = var.frontend_max_size
  min_size           = var.frontend_min_size

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.frontend.arn]

  tag {
    key                 = "Name"
    value              = "${var.project_name}-frontend"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value              = var.environment
    propagate_at_launch = true
  }
}

# Frontend Launch Template
resource "aws_launch_template" "frontend" {
  name_prefix   = "${var.project_name}-frontend-"
  image_id      = local.frontend_ami_id
  instance_type = var.frontend_instance_type
  key_name      = var.frontend_key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [data.terraform_remote_state.network.outputs.frontend_sg_id]
  }

  user_data = base64encode(templatefile("${path.module}/frontend_user_data.sh", {
    project_name = var.project_name
    backend_alb_dns = aws_lb.backend.dns_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-frontend"
      Environment = var.environment
    }
  }
}

# Backend Application Load Balancer
resource "aws_lb" "backend" {
  name               = "${var.project_name}-backend-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [data.terraform_remote_state.network.outputs.backend_alb_sg_id]
  subnets            = data.terraform_remote_state.network.outputs.app_private_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name        = "${var.project_name}-backend-alb"
    Environment = var.environment
  }
}

# Backend Target Group
resource "aws_lb_target_group" "backend" {
  name     = "${var.project_name}-backend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher            = "200"
    path               = "/"
    port               = "traffic-port"
    protocol           = "HTTP"
    timeout            = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.project_name}-backend-tg"
    Environment = var.environment
  }
}

# Backend Listener
resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.backend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

# Backend Auto Scaling Group
resource "aws_autoscaling_group" "backend" {
  name                = "${var.project_name}-backend-asg"
  vpc_zone_identifier = data.terraform_remote_state.network.outputs.app_private_subnet_ids
  desired_capacity    = var.backend_desired_capacity
  max_size           = var.backend_max_size
  min_size           = var.backend_min_size

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.backend.arn]

  tag {
    key                 = "Name"
    value              = "${var.project_name}-backend"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value              = var.environment
    propagate_at_launch = true
  }
}

# Backend Launch Template
resource "aws_launch_template" "backend" {
  name_prefix   = "${var.project_name}-backend-"
  image_id      = local.backend_ami_id
  instance_type = var.backend_instance_type
  key_name      = var.backend_key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [data.terraform_remote_state.network.outputs.backend_sg_id]
  }

  user_data = base64encode(templatefile("${path.module}/backend_user_data.sh", {
    project_name = var.project_name
    db_host     = data.terraform_remote_state.database.outputs.rds_address
    db_username = data.terraform_remote_state.database.outputs.rds_username
    db_password = data.terraform_remote_state.database.outputs.rds_password
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-backend"
      Environment = var.environment
    }
  }
}

# EC2 Key Pair
resource "aws_key_pair" "frontend" {
  key_name   = "frontend-key"
  public_key = file("keys/frontend.pub")
}

resource "aws_key_pair" "backend" {
  key_name   = "backend-key"
  public_key = file("keys/backend.pub")
}