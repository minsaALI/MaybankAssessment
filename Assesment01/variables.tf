variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix used for all resource names"
  type        = string
  default     = "assessment"
}

variable "vpc_cidr" {
  description = "Primary CIDR for the VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs (one per AZ)"
  type        = list(string)
  default     = ["172.16.0.0/24", "172.16.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs (one per AZ)"
  type        = list(string)
  default     = ["172.16.2.0/24", "172.16.3.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones to use (provide 2)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_type_ssm" {
  description = "Instance type for SSM jump host"
  type        = string
  default     = "t3.micro"
}

variable "asg_instance_type" {
  description = "ASG instance type for application servers"
  type        = string
  default     = "t3.small"
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "key_pair_name" {
  description = "EC2 Key pair name to use for instances (optional if using SSM only)"
  type        = string
  default     = ""
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_password" {
  description = "Database master password (sensitive)"
  type        = string
  default     = "change_me"
  sensitive = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}
