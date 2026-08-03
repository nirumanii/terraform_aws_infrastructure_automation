# 1. AWS Provider
provider "aws" {
  region = "us-east-1"
}

# 2. Create VPC
resource "aws_vpc" "nginx_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "nginx_vpc"
  }
}

# 3. Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.nginx_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ngnix_public_subnet"
  }
}

# 4. Create Internet Gateway
resource "aws_internet_gateway" "nginx_igw" {
  vpc_id = aws_vpc.nginx_vpc.id

  tags = {
    Name = "nginx_igw"
  }
}

# 5. Create Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.nginx_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nginx_igw.id
  }

  tags = {
    Name = "nginx-public-route-table"
  }
}

# 6. Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# 7. Generate SSH Private Key
resource "tls_private_key" "nginx_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 8. Create AWS EC2 Key Pair
resource "aws_key_pair" "nginx_key_pair" {
  key_name   = "nginx-terraform-key"
  public_key = tls_private_key.nginx_key.public_key_openssh

  tags = {
    Name = "nginx-terraform-key"
  }
}

# 9. Save Private key locally
resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.nginx_key.private_key_pem
  filename        = "${path.module}/nginx-terraform-key.pem"
  file_permission = "0400"
}

#10. Create Security Group
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-security-group"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.nginx_vpc.id

  # SSH - Port 22
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP - Port 80
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-security-group"
  }
}

# Find Latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create EC2 Instance
resource "aws_instance" "nginx_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  key_name                    = aws_key_pair.nginx_key_pair.key_name
  associate_public_ip_address = true

  tags = {
    Name = "nginx-terraform-server"
  }

  # Wait until private key is saved locally
  depends_on = [
    local_sensitive_file.private_key,
    aws_route_table_association.public_subnet_association
  ]

  # Connect to EC2 through SSH
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.nginx_key.private_key_pem
    host        = self.public_ip
    timeout     = "5m"
  }

  # Install and start Nginx
  provisioner "remote-exec" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install nginx -y",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "sudo systemctl status nginx --no-pager"
    ]
  }
}

# Outputs
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.nginx_vpc.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "ec2_public_ip" {
  description = "Public IP address of the Nginx server"
  value       = aws_instance.nginx_server.public_ip
}

output "nginx_url" {
  description = "Open this URL to access Nginx"
  value       = "http://${aws_instance.nginx_server.public_ip}"
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i nginx-terraform-key.pem ec2-user@${aws_instance.nginx_server.public_ip}"
}