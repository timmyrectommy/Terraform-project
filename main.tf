# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# creating vpc

resource "aws_vpc" "timi_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

# internet gateway

resource "aws_internet_gateway" "timi-gw" {
  vpc_id = aws_vpc.timi_vpc.id

}

# creating route table 


resource "aws_route_table" "timi-route-table" {
  vpc_id = aws_vpc.timi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.timi-gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id             = aws_internet_gateway.timi-gw.id
  }

  tags = {
    Name = "production"
  }
}

# creating subnet

resource "aws_subnet" "pub-sub-1" {
  vpc_id  = aws_vpc.timi_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

}

# subnet route table association

 resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pub-sub-1.id
  route_table_id = aws_route_table.timi-route-table.id
}

# creating security group to allow port 80,443,22

resource "aws_security_group" "allow_web" {
  name        = "allow_web-traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.timi_vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# creating a network interface with ip in the subnets

resource "aws_network_interface" "webserver-net" {
  subnet_id       = aws_subnet.pub-sub-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

# 9. create ubuntu server and install/enable apache2

resource "aws_instance" "web-server-instance" {
  instance_type = "t2.micro"
  ami = "ami-0778521d914d23bc1"
  availability_zone = "us-east-1a"
  key_name = "timi-ubuntu-keys"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.webserver-net.id
  }
    tags = {
        Name = "web-server"
    }    

}