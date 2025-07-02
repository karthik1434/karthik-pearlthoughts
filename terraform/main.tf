terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
}

resource "aws_instance" "mashion" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.medium"
  key_name      = "karthik1"
  subnet_id     = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 16         # Disk size in GB
    volume_type = "gp2"       # General purpose SSD (default)
    delete_on_termination = true
  }
  user_data              = file("user-data.sh")
  
  tags = {
    Name = "${var.name}-minikube"
  }
}

