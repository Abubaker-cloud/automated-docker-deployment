variable "aws_region" {
  description = "AWS region for the project"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "project_name" {
  description = "Project name used in resource tags"
  type        = string
  default     = "automated-docker-deployment"
}

variable "public_key_path" {
  description = "Path to the SSH public key"
  type        = string
  default     = "~/.ssh/ansible-lab-key.pub"
}

variable "key_name" {
  description = "AWS EC2 SSH key pair name"
  type        = string
  default     = "automated-docker-deployment-key"
}

variable "admin_cidr" {
  description = "Administrator public IPv4 CIDR allowed to SSH"
  type        = string
}
