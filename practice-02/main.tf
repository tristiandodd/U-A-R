provider "aws" {
  region = "us-east-1"
}

resource "awaws_launch_configurations_instance" "practice-instances" {
  ami                  = "ami-40d28157"
  instance_type  = "t2.micro"
  user_data         =   <<E0F
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
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "practice-instances-group" {
  launch_configuration = "${aws_launch_configuration.practice-instances.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]  #This is how you pass the names of AZ's avaialble specifically to your AWS account. {data.TYPE.NAME.ATTRIBUTE}
  min_size = 2
  max_size = 10

  tag {
    key                               = "Name"
    value                            = "terraform-asg-example"
    propagate_at_launch    = true
  }
}

