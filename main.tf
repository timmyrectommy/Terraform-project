provider "aws" {
    region = "us-east-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
#variable my_ip {}
variable instance_type {}
variable ami {}
#variable public_key_location {}
variable key_name {}


resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name = "${var.env_prefix}-igw"
    }
}

resource "aws_route_table" "main-rtb" {
    vpc_id = aws_vpc.myapp-vpc.id
    #default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name = "${var.env_prefix}-main-rtb"
    }
}

 resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.main-rtb.id
}

resource "aws_security_group" "timi-sg" {
  name        = "timi-sg"
  #description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.myapp-vpc.id

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
    description      = "HTTP"
    from_port        = 8080
    to_port          = 8080
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
        Name = "${var.env_prefix}-timi-sg"
    }
}


/*
resource "aws_security_group_rule" "web-http" {
  security_group_id = aws_vpc.myapp-vpc.default_security_group_id
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "server-ssh" {
  security_group_id = aws_vpc.myapp-vpc.default_security_group_id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip]
}
*/
/*
data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}


output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

output "ec2_public_ip" {
    value = aws_instance.myapp-server.public_ip
}

resource "aws_key_pair" "ssh-key" {
    key_name = "timi-ubuntu-key"
   # public_key = file(var.public_key_location)
}
*/


resource "aws_instance" "myapp-server" {
    #ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type
    ami = var.ami

    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_security_group.timi-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = true
    key_name = var.key_name

   # user_data = file("entry-script.sh")
   provisioner "file" {
    source = "entry-script.sh"
    destination = "/tmp/entry-script.sh"
   }


   connection {
    user = "ubuntu"
    #private_key = file("private_key = aws_key_pair.my_key_pair.private_key")

    host = self.public_ip
   }

    tags = {
        Name = "${var.env_prefix}-server"
    }
}