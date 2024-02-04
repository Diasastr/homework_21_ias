variable "region" {
  description = "AWS Deployment region.."
  default = "eu-north-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  description = "A list of public subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnets_cidr" {
  description = "A list of private subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.3.0/24"]
}

variable "environment" {
  description = "The environment name."
  default     = "prod"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = data.aws_availability_zones.available.names
}
