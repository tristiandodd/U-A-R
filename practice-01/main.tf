provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "practice-instances" {
  ami                 = "ami-40d28157"
  instance_type = "t2.micro"

  user_data =   <<E0F
                    #!/bin/bash
                    echo "Hello, World"  >  index.html
                    nohup busybox httpd -f  -p 8080 &
                    E0F

  tags {
    Name    = "terraform-practice"
  }
}

resource "aws_security_group" "example-sg" {
    name = "terraform-practice-instances"

    ingress {
        from_port       = 8080
        to_port            = 8080
        protocol          = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

