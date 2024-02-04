/*==== The VPC ======*/
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}
/*==== Subnets ======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-igw"
    Environment = "${var.environment}"
  }
}
/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.ig]
  tags = {
    Name        = "nat"
    Environment = "${var.environment}"
  }
}
/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, 0)}"
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "nat"
    Environment = "${var.environment}"
  }
}
/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.public_subnets_cidr)}"
  cidr_block              = "${element(var.public_subnets_cidr,   count.index)}"
  availability_zone       = "${element(var.availability_zones,   count.index)}"
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-      public-subnet"
    Environment = "${var.environment}"
  }
}
/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.private_subnets_cidr)}"
  cidr_block              = "${element(var.private_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.availability_zones,   count.index)}"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-private-subnet"
    Environment = "${var.environment}"
  }
}
/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-private-route-table"
    Environment = "${var.environment}"
  }
}
/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = "${var.environment}"
  }
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}
/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}
/*==== VPC's Default Security Group ======*/
resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${aws_vpc.vpc.id}"
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "jenkins_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["13.48.4.200/30"]
    description = "Allow SSH for EC2 Instance Connect"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-jenkins-sg"
    Environment = var.environment
    Role        = "jenkins"
  }
}

resource "aws_security_group" "app_server_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
    description = "Allow SSH from Jenkins Controller"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-app-server-sg"
    Environment = var.environment
    Role        = "application"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("${path.module}/deployer-key.pub")
}

resource "aws_instance" "jenkins_controller" {
  ami           = "ami-0f82e2c40f84cae0d" # Amazon linux 2
  instance_type = "t3.small"
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  tags = {
    Name        = "${var.environment}-jenkins-controller"
    Environment = var.environment
    Role        = "jenkins"
  }
}

resource "aws_instance" "app_server" {
  ami                    = "ami-0f82e2c40f84cae0d" # Amazon Linux 2
  instance_type          = "t3.small"
  subnet_id              = element(aws_subnet.public_subnet.*.id, 0)
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]

  tags = {
    Name        = "${var.environment}-app-server"
    Environment = var.environment
    Role        = "application"
  }
}
