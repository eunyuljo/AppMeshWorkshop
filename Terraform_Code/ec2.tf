# Private Key 생성
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# EC2 키 페어 생성
resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "terraform_key_${var.stack_name}"
  public_key = tls_private_key.example.public_key_openssh
}

# 개인 키를 로컬에 저장
resource "local_file" "private_key" {
  filename = "${path.module}/terraform_key_${var.stack_name}.pem"
  content  = tls_private_key.example.private_key_pem
  file_permission = "0600"
}

# IAM 인스턴스 프로파일
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile-${var.stack_name}"
  role = aws_iam_role.ec2_instance_role.name
}

# EC2 인스턴스용 보안 그룹
resource "aws_security_group" "ec2_instance_sg" {
  vpc_id = aws_vpc.main.id

  description = "Security group for EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}

# EC2 인스턴스 생성
resource "aws_instance" "ec2_external_instance" {
  ami           = var.latest_ami_id   # CloudFormation에서 ImageId를 참조
  instance_type = "t3.micro"          # 인스턴스 타입 설정
  key_name      = aws_key_pair.ec2_key_pair.key_name  # 키 페어 참조
  subnet_id     = aws_subnet.private_subnet_one.id    # 프라이빗 서브넷 참조
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name  # IAM 인스턴스 프로파일 참조

  vpc_security_group_ids = [aws_security_group.ec2_instance_sg.id]  # 보안 그룹 설정

  tags = {
    Name  = "External-EC2Instance-${var.stack_name}"
    Usage = "ExternalEC2Instance"
  }

  # UserData 스크립트를 실행하여 초기 설정 수행
  user_data = base64encode(<<-EOF1
    #!/bin/bash -ex
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

    # tools script
    cat > /home/ec2-user/install-tools <<-"EOF2"

    #!/bin/bash -ex
    sudo yum install -y jq bash-completion

    sudo curl --silent --location -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.16.8/bin/linux/amd64/kubectl
    sudo chmod +x /usr/local/bin/kubectl
    echo 'source <(kubectl completion bash)' >>/home/ec2-user/.bashrc

    if ! [ -x "$(command -v jq)" ] || ! [ -x "$(command -v envsubst)" ] || ! [ -x "$(command -v kubectl)" ]; then
      echo 'ERROR: tools not installed.' >&2
      exit 1
    fi

    pip install awscli --upgrade --user

    EOF2

    chmod +x /home/ec2-user/install-tools
    /home/ec2-user/install-tools
  EOF1
  )
}
