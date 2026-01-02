provider "aws" {
    access_key = ""
    secret_key = ""
  region = ""
}

resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "vpc1"
    }
  
}
#public subnet block
resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    tags = {
      Name="PUBLIC-SUBNET"
    }
  
}
#private subnet block
resource "aws_subnet" "private-subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = "true"
    
    tags = {
      Name="PRIVATE-SUBNET"
    }

}
#igw block
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name="VPC-IGW"
    }
  
}
#default rt
resource "aws_default_route_table" "vpc-drt" {
    default_route_table_id = aws_vpc.vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      Name="PUBLIC-RT"
    }
  
}
#private rt
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name="PRIVATE_RT"
  }
  
}
#subnet association 
resource "aws_route_table_association" "subnet association" {
  subnet_id = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
  
  }
  #elastic ip
  resource "aws_eip" "eip" {
    domain = "vpc"
    
  }
  #nat 
  resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.eip.id
    subnet_id = aws_subnet.public-subnet.id
    tags = {
      Name="NAT"
    }
    
  }
  #security group
resource "aws_default_security_group" "vpc-sg" {
    vpc_id = aws_vpc.vpc.id

    ingress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]

    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]

    }
    tags = {
      Name="VPC-SG"
    }
}
#ec2 instance
resource "aws_instance" "ubuntu_machine" {
  ami = "ami-00d8fc944fb171e29"
  instance_type = "t3.micro"
  key_name = "vani1"
  associate_public_ip_address = "true"
  subnet_id = aws_subnet.public-subnet.id
  #vpc_security_group_ids = [ aws_default_security_group.vpc-sg.id ]
  tags = {
    Name="PUBLIC-SERVER"
  }
  
}
resource "aws_instance" "ubuntu_machine2" {
  ami = "ami-00d8fc944fb171e29"
  instance_type = "t3.micro"
  key_name = "vani1"
  associate_public_ip_address = "true"
  subnet_id = aws_subnet.private-subnet.id
  tags = {
    Name="PRIVATE-SERVER"
  }
  
}

