provider "aws" {
region = "ap-south-1"
access_key = "AKIA3FLD2AX5CFOGMLVE"
secret_key = "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"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/24"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id
}
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/25"
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block ="10.0.0.128/25"
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.my_vpc.id
}
resource "aws_route" "private_route_out" {
  route_table_id            = aws_route_table.private_route.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route.id
}
resource "aws_instance" "app_server" {
  ami           ="ami-0451f2687182e0411"
  instance_type = "t2.micro"
  key_name      = "master"
  count         = "1"
  tags = {
   Name= "application"
}
  subnet_id     = aws_subnet.public_subnet.id

}

resource "aws_instance" "db_server" {
  ami           = "ami-0451f2687182e0411"
  instance_type = "t2.micro"
  key_name      = "master"
  count         = "1"
    tags = {
   Name= "database"
}

  subnet_id     = aws_subnet.private_subnet.id
  # Add other necessary configurations
}
