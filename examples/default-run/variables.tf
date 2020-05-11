
variable "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks for the Public Subnets inside the VPC."
}

variable "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks for the Private Subnets inside the VPC."
}

variable "azs" {
  description = "List of availability zones in the region."
}

variable "vpc_cidr_block" {
  description = "Primary CIDR block for the VPC."
}


variable "ami_id" {
  description = "If network creation set to false, user has to pass the subnet id"
}

variable "instance_type" {}

variable "bucket_name" {}

variable "Source_Machine_Public_IP" {
  description = "From which source do you want to access NGINX. "
}

variable "terraform_machine_public_ip" {
  description = "Terraform machine Public IP Used for remote-exec"
}

variable "resource_name_prefix" {}