
data "aws_availability_zones" "available" {
  state = "available"  # 가용 상태인 AZ만 가져옵니다.
}

# VPC 설정
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-${var.stack_name}"
  }
}

# Public 서브넷 1
resource "aws_subnet" "public_subnet_one" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicOne-${var.stack_name}"
  }
}

# Public 서브넷 2
resource "aws_subnet" "public_subnet_two" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicTwo-${var.stack_name}"
  }
}

# Public 서브넷 3
resource "aws_subnet" "public_subnet_three" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicThree-${var.stack_name}"
  }
}

# Private 서브넷 1
resource "aws_subnet" "private_subnet_one" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "PrivateOne-${var.stack_name}"
  }
}

# Private 서브넷 2
resource "aws_subnet" "private_subnet_two" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "PrivateTwo-${var.stack_name}"
  }
}

# Private 서브넷 3
resource "aws_subnet" "private_subnet_three" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.102.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "PrivateThree-${var.stack_name}"
  }
}



# 인터넷 게이트웨이
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IGW-${var.stack_name}"
  }
}

# NAT 게이트웨이용 EIP (Elastic IP)
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "NatElasticIP"
  }
}

# NAT 게이트웨이 (하나만 사용)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_one.id # Public 서브넷 1에 배치
}



# Public 라우팅 테이블
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable-${var.stack_name}"
  }
}

# Public 서브넷과 라우팅 테이블 연결
resource "aws_route_table_association" "public_subnet_one_association" {
  subnet_id      = aws_subnet.public_subnet_one.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_two_association" {
  subnet_id      = aws_subnet.public_subnet_two.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_three_association" {
  subnet_id      = aws_subnet.public_subnet_three.id
  route_table_id = aws_route_table.public_rt.id
}

# Private 라우팅 테이블 (하나의 NAT 게이트웨이를 사용)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "PrivateRouteTable-${var.stack_name}"
  }
}

# Private 서브넷과 라우팅 테이블 연결
resource "aws_route_table_association" "private_subnet_one_association" {
  subnet_id      = aws_subnet.private_subnet_one.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_subnet_two_association" {
  subnet_id      = aws_subnet.private_subnet_two.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_subnet_three_association" {
  subnet_id      = aws_subnet.private_subnet_three.id
  route_table_id = aws_route_table.private_rt.id
}
