//1st step make aws-key-pair using (ssh-keygen) for generating key

resource "aws_key_pair" "rhys_key" {
  key_name   = "rhys-ec2-key"
  public_key = file("~/.ssh/rhys-ec2-key.pub")
}

# 2nd create vpc and subnet
resource "aws_vpc" "rhys_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "rhys-vpc"
  }
}

resource "aws_subnet" "rhys_subnet" {
  cidr_block              = "10.0.0.0/24"
  vpc_id                  = aws_vpc.rhys_vpc.id
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "rhys_subnet"

  }
}

// 3rd create internetgateway and routetable
resource "aws_internet_gateway" "rhys_ig" {
  vpc_id = aws_vpc.rhys_vpc.id


  tags = {
    Name = "rhys_ig"
  }
}

resource "aws_route_table" "rhys_route_table" {
  vpc_id = aws_vpc.rhys_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rhys_ig.id
  }
  tags = {
    Name = "rhys_route_table"
  }

}

// 4rth create route table association
resource "aws_route_table_association" "rhys_route_association" {
  subnet_id      = aws_subnet.rhys_subnet.id
  route_table_id = aws_route_table.rhys_route_table.id
}


//5th create security group 
resource "aws_security_group" "rhys_security_groups" {
  name        = "rhys_sg"
  description = "this will create sg"
  vpc_id      = aws_vpc.rhys_vpc.id


  ## inbound rule 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "SSH open"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "HTTPS open"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP open"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "all acess open out bound"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "rhys_security_group"
  }
}

resource "aws_instance" "mine_ec2" {
  for_each = tomap({
    "rhys-ec2"      = "t3.micro"
    "prod-instance" = "t3.micro"
    "dev-instance"  = "t3.micro"
    "env-ec2"       = "t3.micro"
  })
  instance_type          = each.value
  subnet_id              = aws_subnet.rhys_subnet.id
  vpc_security_group_ids = [aws_security_group.rhys_security_groups.id]
  key_name               = aws_key_pair.rhys_key.key_name
  ami                    = var.ami_id


  tags = {
    Name = each.key
  }
}
