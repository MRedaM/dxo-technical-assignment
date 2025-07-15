variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix for naming all resources"
  type        = string
  default     = "dxo"
}

variable "public_key_path" {
  description = "Path to your local public SSH key (.pub)"
  type        = string
  default     = "~/.ssh/dxo-key.pub"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami" {
  description = "Ubuntu 22.04 AMI ID for us-east-1"
  type        = string
  default     = "ami-053b0d53c279acc90"
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS listener"
  type        = string
}
