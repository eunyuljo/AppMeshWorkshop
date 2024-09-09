# Launch Template for Ruby EC2 Instances
resource "aws_launch_template" "ruby_ec2_instance_lt" {
  name_prefix   = "Ruby-EC2Instance-LaunchTemplate-${var.stack_name}"
  image_id      = var.latest_ami_id
  instance_type = "t3.medium"
  key_name      = aws_key_pair.ec2_key_pair.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  # 보안 그룹을 이름 대신 ID로 지정
  vpc_security_group_ids = [aws_security_group.ec2_instance_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash -ex
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

    # Install required libs
    yum install -y git gcc gcc-c++ make readline-devel openssl-devel sqlite-devel gmp-devel jq
    
    # Install rbenv
    git clone https://github.com/rbenv/rbenv.git /tmp/.rbenv
    echo 'export PATH="/tmp/.rbenv/bin:/usr/local/bin:$PATH"' >> /tmp/.bashrc
    echo 'eval "$(rbenv init -)"' >> /tmp/.bashrc
    source /tmp/.bashrc

    # Install ruby-build
    git clone https://github.com/rbenv/ruby-build.git /tmp/ruby-build
    cd /tmp/ruby-build
    ./install.sh

    rbenv install 2.5.1 && rbenv global 2.5.1

    # Install rails and bundler
    gem install --force rails:4.2.10 bundler:1.17.3
    gem update --system

    # Clone the repo and build the app
    export RUBY_ROOT=/tmp/ecsdemo-frontend
    git clone https://github.com/ffeijoo/ecsdemo-frontend.git /tmp/ecsdemo-frontend
    cd $RUBY_ROOT
    bundle update --bundler
    bundle install

    # Set environment variables for routing
    export MESH_RUN='true'
    export CRYSTAL_URL='http://crystal.appmeshworkshop.hosted.local:3000/crystal'
    export NODEJS_URL='http://nodejs.appmeshworkshop.hosted.local:3000'

    # Run at boot
    sed -i '$ d' startup.sh && echo 'rails s -e production -b 0.0.0.0' >> startup.sh
    nohup ./startup.sh &
  EOF
  )

  tag_specifications {
    resource_type = "instance"

  tags = {
    Name = "Ruby-EC2Instance-${var.stack_name}"
  }
 }
}


# Auto Scaling Group for Ruby EC2 Instances
resource "aws_autoscaling_group" "ruby_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 2
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.ruby_ec2_instance_lt.id
    version = "$Latest"
  }

  vpc_zone_identifier = [
    aws_subnet.public_subnet_one.id,  # Ensure that these subnets are in the correct VPC
    # aws_subnet.public_subnet_two.id,  # not support - spectific type
    aws_subnet.public_subnet_three.id
  ]

  target_group_arns = [
    aws_lb_target_group.ruby_target_group.arn
  ]
}

# Security Group for Internal Load Balancer
resource "aws_security_group" "internal_lb_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SecurityGroup-InternalLoadBalancer-${var.stack_name}"
  }
}

# Internal Load Balancer
resource "aws_lb" "internal_load_balancer" {
  name               = "IntLB-${var.stack_name}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_lb_sg.id]
  subnets            = [
    aws_subnet.private_subnet_one.id,
    # aws_subnet.private_subnet_two.id,
    aws_subnet.private_subnet_three.id
  ]

  tags = {
    Name = "Internal-LB-${var.stack_name}"
  }
}

# Internal Listener for Load Balancer
resource "aws_lb_listener" "internal_listener" {
  load_balancer_arn = aws_lb.internal_load_balancer.arn
  port              = 3000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ruby_target_group.arn
  }
}

# Target Group for Ruby Application
resource "aws_lb_target_group" "ruby_target_group" {
  name        = "RubyTargetGroup"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "RubyTargetGroup-${var.stack_name}"
  }
}

