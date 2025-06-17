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
  ami           = "ami-0e35ddab05955cf57"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              
              docker pull duggana1994/strapi-app:latest
              docker run -d -p 1337:1337 --name strapi-app duggana1994/strapi-app:latest
              EOF

  tags = {
    Name = "${var.name}-ubuntu"
  }
}