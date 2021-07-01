# Webserver with auto scaling group & application load balancer

Creates a simple webserver that displays the private ip-address of the EC2 instance.

## Stack

* 1x Auto scaling group
* 1x Launch template (default instance type is t2.micro & eu-west-1 linux AMI)
* 1x Application load balancer
* 1x Target group for the ALB
* 1x HTTP listener listening on port 80
* 1x VPC (created with the VPC module, by default creates a subnet for each availability zone specified)
