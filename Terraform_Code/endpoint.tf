# VPC 엔드포인트 보안 그룹 생성
resource "aws_security_group" "vpc_endpoint_sg" {
  vpc_id = aws_vpc.main.id

  description = "Security Group for VPC Endpoints"
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPCEndpointSecurityGroup-${var.stack_name}"
  }
}

# EC2 엔드포인트
resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [
    aws_subnet.private_subnet_one.id,
    aws_subnet.private_subnet_two.id,
    aws_subnet.private_subnet_three.id,
  ]
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "EC2Endpoint-${var.stack_name}"
  }
}

# EC2 메시지 엔드포인트
resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [
    aws_subnet.private_subnet_one.id,
    aws_subnet.private_subnet_two.id,
    aws_subnet.private_subnet_three.id,
  ]
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "EC2MessagesEndpoint-${var.stack_name}"
  }
}

# ECR API 엔드포인트
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [
    aws_subnet.private_subnet_one.id,
    aws_subnet.private_subnet_two.id,
    aws_subnet.private_subnet_three.id,
  ]
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "ECREndpointAPI-${var.stack_name}"
  }
}

# ECR DKR 엔드포인트
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [
    aws_subnet.private_subnet_one.id,
    aws_subnet.private_subnet_two.id,
    aws_subnet.private_subnet_three.id,
  ]
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "ECREndpointDKR-${var.stack_name}"
  }
}

# CloudWatch 엔드포인트
resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [
    aws_subnet.private_subnet_one.id,
    aws_subnet.private_subnet_two.id,
    aws_subnet.private_subnet_three.id,
  ]
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "CloudWatchEndpoint-${var.stack_name}"
  }
}

# SSM 엔드포인트
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [
    aws_subnet.private_subnet_one.id,
    aws_subnet.private_subnet_two.id,
    aws_subnet.private_subnet_three.id,
  ]
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "SSMEndpoint-${var.stack_name}"
  }
}

# SSM 메시지 엔드포인트
resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [
    aws_subnet.private_subnet_one.id,
    aws_subnet.private_subnet_two.id,
    aws_subnet.private_subnet_three.id,
  ]
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "SSMMessagesEndpoint-${var.stack_name}"
  }
}
