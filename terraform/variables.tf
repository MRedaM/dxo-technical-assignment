variable "region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "dxo"
}

variable "public_key_path" {
  default = "~/.ssh/dxo-key.pub"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "ami" {
  description = "Ubuntu 22.04 AMI ID for us-east-1"
  default     = "ami-053b0d53c279acc90"
}