variable "region" {
  default = "us-east-1"
}

variable "project" {
  default     = "devops"
}

variable "environment" {
  default     = "dev"
}

variable "cidr_block" {
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr_blocks" {
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "availability_zones" {
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_cidr_address" {
    default = "0.0.0.0/0"
}


variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the VPC resources"
}
