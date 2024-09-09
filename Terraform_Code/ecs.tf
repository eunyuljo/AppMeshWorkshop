# ECR Repository for Crystal Application
resource "aws_ecr_repository" "crystal" {
  name = "crystal-${var.stack_name}"

  tags = {
    Name = "ECRCrystal-${var.stack_name}"
  }
}

# ECR Repository for NodeJS Application
resource "aws_ecr_repository" "nodejs" {
  name = "nodejs-${var.stack_name}"

  tags = {
    Name = "ECRNodeJS-${var.stack_name}"
  }
}

# Target Group for Crystal Application
resource "aws_lb_target_group" "crystal_target_group" {
  name        = "CrystalTargetGroup"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip" # Fargate

  health_check {
    path                = "/health"
    port                = "3000"  # 명시적으로 포트 3000을 추가
    protocol            = "HTTP"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "CrystalTargetGroup"
  }

  # depends_on = [
  #   aws_lb_listener.internal_listener
  # ]
}

# Load Balancer Listener for External Load Balancer
resource "aws_lb_listener" "external_listener" {
  load_balancer_arn = aws_lb.external_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.crystal_target_group.arn
  }

  # depends_on = [
  #   aws_lb_listener.crystal_target_group
  # ]

}


# Elastic Load Balancer (External)
resource "aws_lb" "external_load_balancer" {
  name               = "ExtLB-${var.stack_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.external_lb_sg.id]
  subnets            = [
    aws_subnet.public_subnet_one.id,
    aws_subnet.public_subnet_two.id,
    aws_subnet.public_subnet_three.id
  ]

  tags = {
    Name = "External-LB-${var.stack_name}"
  }
}

# Security Group for External Load Balancer
resource "aws_security_group" "external_lb_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SecurityGroup-ExternalLoadBalancer-${var.stack_name}"
  }
}



# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "cluster-${var.stack_name}"

  tags = {
    Name = "ECSCluster-${var.stack_name}"
  }
}

# ECS Task Definition for Crystal Application
resource "aws_ecs_task_definition" "crystal_task" {
  family                = "crystal-task-${var.stack_name}"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = "256"
  memory                = "512"
  execution_role_arn    = aws_iam_role.ecs_service_role.arn
  task_role_arn         = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name  = "crystal-service"
    image = "${aws_ecr_repository.crystal.repository_url}:vanilla"
    portMappings = [{
      containerPort = 3000
      protocol      = "http"
    }]
    essential      = true
    healthCheck = {
      command     = ["CMD-SHELL", "curl -s http://localhost:3000/health | grep -q Healthy!"]
      interval    = 5
      retries     = 3
      startPeriod = 10
      timeout     = 2
    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name
        "awslogs-region"        = "ap-northeast-2"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# CloudWatch Log Group for ECS Task logs
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/crystal-service"
  retention_in_days = 7  # 로그 유지 기간을 원하는 대로 설정하세요

  tags = {
    Name = "ECSLogGroup-${var.stack_name}"
  }
}

