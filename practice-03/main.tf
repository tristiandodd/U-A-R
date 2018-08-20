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

  load_balancers        = ["${aws_elb.example.name}"]
  health_check_type  = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                               = "Name"
    value                            = "terraform-asg-example"
    propagate_at_launch    = true
  }
}

resource     "aws_security_group" "elb" {
    name = "terraform-example-elb"

    ingress {
        from_port       = 80
        to_port            = 80
        protocol          = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

resource "aws_elb" "example" {
    name                     = "terraform-asg-example"
    availability_zones = ["${data.aws_availability_zones.all.names}"]
    security_groups     = ["${aws_security_group.elb.id}"]

    listener {
        from_port             = 80
        lb_protocol           = "http"
        instance_port        = "${var.server_port}"
        instance_protocol = "http"
    }

    health_check {                                                          #Health check request
        healthy_threshold     = 2
        unhealthy_threshold = 2
        timeout                      = 3
        interval                      = 30
        target                         = "HTTP:${var.server_port}/"
    }
}

