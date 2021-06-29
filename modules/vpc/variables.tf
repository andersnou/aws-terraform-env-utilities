variable "environment" {
  type = string
  default = "dev"
}

variable "availability_zones" {
  type = list(string)
  default = ["eu-west-1a", "eu-west-1b"]
}

variable "create_private_subnets" {
  type = bool
  default = false
}

variable "prefix" {
  type = string
  default = ""
}

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
}