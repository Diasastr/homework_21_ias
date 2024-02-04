variable "region" {
  description = "AWS Deployment region."
  type        = string
  default     = "eu-north-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  description = "A list of public subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  description = "A list of private subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "environment" {
  description = "The environment name."
  type        = string
  default     = "prod"
}

variable "availability_zones" {
  description = "A list of production availability zones."
  type        = list(string)// Note: We do not set a default here because this should be dynamically passed from the root module
}
