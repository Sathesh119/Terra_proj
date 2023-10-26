resource "aws_s3_bucket" "b" {
  bucket = "my-test-bucket-119"
}
terraform {
  backend "s3" {
    bucket = "my-test-bucket-119"
    key    = "terra/terraform.tfstate"
    region = "ap-northeast-1"

  }
}

# Create a VPC
resource "aws_vpc" "My_vpc" {
  cidr_block = "10.0.0.0/16"

}

# Create a public subnet
resource "aws_subnet" "Public_Subnet" {
  vpc_id            = aws_vpc.My_vpc.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.1.0/24"

}

# Create a IGW
resource "aws_internet_gateway" "My_IGW" {
  vpc_id = aws_vpc.My_vpc.id

}
# Create a route table
resource "aws_route_table" "Custom_RT" {
  vpc_id = aws_vpc.My_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.My_IGW.id
  }
}

# Create RT association
resource "aws_route_table_association" "PublicRTassociation" {
  subnet_id      = aws_subnet.Public_Subnet.id
  route_table_id = aws_route_table.Custom_RT.id

}

# Create an ec2 instance
resource "aws_instance" "app_server" {
  ami           = "ami-0d48337b7d3c86f62"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.Public_Subnet.id


}
#Create an EBSVol
resource "aws_ebs_volume" "ebsvol" {

  availability_zone = "ap-northeast-1a"
  size              = 1

  tags = {
    Name = "HelloWorld"
  }
}
#Attach the volume
resource "aws_volume_attachment" "ebs_attach" {
  instance_id = aws_instance.app_server.id
  volume_id   = aws_ebs_volume.ebsvol.id
  device_name = "/dev/sdh"
}
