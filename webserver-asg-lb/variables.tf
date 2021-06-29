variable "region" {
  type = string
  default = "eu-west-1"
}

variable "ami" {
  type = string
  default = "ami-063d4ab14480ac177"
}

variable "asg_max_size" {
  type = number
  default = 2
}

variable "asg_min_size" {
  type = number
  default = 1
}

variable "availability_zones" {
  type = list(string)
  default = ["eu-west-1a", "eu-west-1b"]
}
