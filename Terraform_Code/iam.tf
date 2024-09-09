# ECS 서비스 역할
resource "aws_iam_role" "ecs_service_role" {
  name = "ECSServiceRole-${var.stack_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = [
          "ecs.amazonaws.com",
          "ecs-tasks.amazonaws.com"
        ]
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "ECSServiceRole-${var.stack_name}"
  }
}

# ECS 서비스 역할 정책
resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "ECSServiceRolePolicy-${var.stack_name}"
  role   = aws_iam_role.ecs_service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:AttachNetworkInterface",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    }]
  })
}

# ECS 태스크 역할
resource "aws_iam_role" "ecs_task_role" {
  name = "ECSTaskRole-${var.stack_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "ECSTaskRole-${var.stack_name}"
  }
}

# ECS 태스크 역할 정책
resource "aws_iam_role_policy" "ecs_task_role_policy" {
  name   = "ECSTaskRolePolicy-${var.stack_name}"
  role   = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ]
      Resource = "*"
    }]
  })
}

# EC2 인스턴스 역할
resource "aws_iam_role" "ec2_instance_role" {
  name = "EC2InstanceRole-${var.stack_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "EC2InstanceRole-${var.stack_name}"
  }
}

# EC2 인스턴스 역할 정책 (SSM 접근)
resource "aws_iam_role_policy" "ec2_instance_role_policy" {
  name   = "EC2InstanceRolePolicy-${var.stack_name}"
  role   = aws_iam_role.ec2_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ssm:DescribeInstanceInformation",
        "ssm:SendCommand",
        "ssm:GetCommandInvocation",
        "ssm:ListCommandInvocations",
        "ssm:PutInventory",
        "ssm:GetInventory",
        "ssm:DeleteInventory",
        "ec2:DescribeInstances",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage"
      ]
      Resource = "*"
    }]
  })
}

# Lambda 실행 역할
resource "aws_iam_role" "lambda_execution_role" {
  name = "LambdaExecutionRole-${var.stack_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "LambdaExecutionRole-${var.stack_name}"
  }
}

# Lambda 역할 정책
resource "aws_iam_role_policy" "lambda_execution_policy" {
  name   = "LambdaExecutionPolicy-${var.stack_name}"
  role   = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ec2:CreateKeyPair",
        "ec2:DeleteKeyPair",
        "ssm:PutParameter",
        "ssm:DeleteParameter",
        "kms:Encrypt",
        "kms:Decrypt"
      ]
      Resource = "*"
    }]
  })
}
