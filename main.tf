provider "aws" {
  region     = "us-east-2"
  access_key = "AKIA4Z62VICD4WKGQHG7"
  secret_key = "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"
}

resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "lab_vpc"
  }
}

resource "aws_subnet" "subnet0" {
  vpc_id            = aws_vpc.lab_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "subnet0"
  }
}

resource "aws_internet_gateway" "lab-gateway" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "labgate"
  }
}

resource "aws_eip" "eip" {
  instance = aws_instance.server0.id
  vpc      = true
}

resource "aws_route_table" "labtable" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab-gateway.id
  }
  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.lab-gateway.id
  }

  tags = {
    Name = "labroute"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet0.id
  route_table_id = aws_route_table.labtable.id

}

resource "aws_network_interface" "server0-nic" {
  subnet_id       = aws_subnet.subnet0.id
  security_groups = [aws_security_group.lab_sg.id]
  private_ip = "10.0.1.50"
  tags = {
    name = "server0-nic"
  }
}

resource "aws_security_group" "lab_sg" {
  name        = "allow traffic"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.lab_vpc.id

ingress {
  description = "In-Traffic"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

egress {
  description = ")ut-Traffic"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

tags = {
  Name = "lab_sg"
}
}

resource "aws_instance" "server0" {
ami               = "ami-03a0c45ebc70f98ea"
instance_type     = "t2.micro"
availability_zone = "us-east-2a"
key_name          = "tmac01"

network_interface {
  device_index         = 0
#  private_ip = "10.0.0.50"
  network_interface_id = aws_network_interface.server0-nic.id
}
user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install default-jdk -y
              sudo apt-get install git python2 python3 python-pip -y
              sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
              curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
              sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
              sudo apt-get update && sudo apt-get install terraform
              EOF
tags = {
  Name = "server0"
}
}















# # 1. Create vpc

# resource "aws_vpc" "prod-vpc" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "production"
#   }
# }

# # 2. Create Internet Gateway

# resource "aws_internet_gateway" "gw" {
#   vpc_id = aws_vpc.prod-vpc.id


# }
# # 3. Create Custom Route Table

# resource "aws_route_table" "prod-route-table" {
#   vpc_id = aws_vpc.prod-vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.gw.id
#   }

#   route {
#     ipv6_cidr_block = "::/0"
#     gateway_id      = aws_internet_gateway.gw.id
#   }

#   tags = {
#     Name = "Prod"
#   }
# }

# # 4. Create a Subnet 

# resource "aws_subnet" "subnet-1" {
#   vpc_id            = aws_vpc.prod-vpc.id
#   cidr_block        = "10.0.1.0/24"
#   availability_zone = "us-east-1a"

#   tags = {
#     Name = "prod-subnet"
#   }
# }

# # 5. Associate subnet with Route Table
# resource "aws_route_table_association" "a" {
#   subnet_id      = aws_subnet.subnet-1.id
#   route_table_id = aws_route_table.prod-route-table.id
# }
# # 6. Create Security Group to allow port 22,80,443
# resource "aws_security_group" "allow_web" {
#   name        = "allow_web_traffic"
#   description = "Allow Web inbound traffic"
#   vpc_id      = aws_vpc.prod-vpc.id

#   ingress {
#     description = "HTTPS"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     description = "HTTP"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "allow_web"
#   }
# }

# # 7. Create a network interface with an ip in the subnet that was created in step 4

# resource "aws_network_interface" "web-server-nic" {
#   subnet_id       = aws_subnet.subnet-1.id
#   private_ips     = ["10.0.1.50"]
#   security_groups = [aws_security_group.allow_web.id]

# }
# # 8. Assign an elastic IP to the network interface created in step 7

# resource "aws_eip" "one" {
#   vpc                       = true
#   network_interface         = aws_network_interface.web-server-nic.id
#   associate_with_private_ip = "10.0.1.50"
#   depends_on                = [aws_internet_gateway.gw]
# }

# output "server_public_ip" {
#   value = aws_eip.one.public_ip
# }

# # 9. Create Ubuntu server and install/enable apache2

# resource "aws_instance" "web-server-instance" {
#   ami               = "ami-085925f297f89fce1"
#   instance_type     = "t2.micro"
#   availability_zone = "us-east-1a"
#   key_name          = "main-key"

#   network_interface {
#     device_index         = 0
#     network_interface_id = aws_network_interface.web-server-nic.id
#   }

#   user_data = <<-EOF
#                 #!/bin/bash
#                 sudo apt update -y
#                 sudo apt install apache2 -y
#                 sudo systemctl start apache2
#                 sudo bash -c 'echo your very first web server > /var/www/html/index.html'
#                 EOF
#   tags = {
#     Name = "web-server"
#   }
# }



# output "server_private_ip" {
#   value = aws_instance.web-server-instance.private_ip

# }

# output "server_id" {
#   value = aws_instance.web-server-instance.id
# }


# resource "<provider>_<resource_type>" "name" {
#     config options.....
#     key = "value"
#     key2 = "another value"
# }
