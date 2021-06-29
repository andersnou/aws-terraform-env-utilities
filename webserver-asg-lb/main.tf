provider "aws" {
  region = var.region
}

resource "aws_launch_template" "launch_template" {
  name_prefix = "webserver_template"
  image_id = var.ami
  instance_type = "t2.micro"

  vpc_security_group_ids = module.vpc.security_groups_ids

  user_data = filebase64("./webserver.sh")

}

resource "aws_autoscaling_group" "asg" {
  max_size = var.asg_max_size
  min_size = var.asg_min_size
  desired_capacity = var.asg_max_size

  vpc_zone_identifier = module.vpc.public_subnet_ids
  target_group_arns = [aws_alb_target_group.tg.arn]

  launch_template {
    id = aws_launch_template.launch_template.id
    version = "$Latest"
  }
}

resource "aws_alb_target_group" "tg" {
  name = "webserver-alb-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = module.vpc.vpc_id
}

resource "aws_lb" "lb" {
  name = "webserver-lb"
  internal = false
  load_balancer_type = "application"

  security_groups = module.vpc.security_groups_ids
  subnets = module.vpc.public_subnet_ids
}

resource "aws_lb_listener" "http_forward" {
  load_balancer_arn = aws_lb.lb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.tg.arn
  }
}

module "vpc" {
  source = "../modules/vpc"

  availability_zones = var.availability_zones
  prefix = "webserver"
  environment = "dev"
  create_private_subnets = false
}