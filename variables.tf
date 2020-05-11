#Common
variable "region" {}

variable "access_key" {}

variable "secret_key" {}

variable "token" {}
variable "bucket_name" {}


#Networking Setup Variables

variable "create_networking_resources" {
  description = "Networking setup required or not. Default True. If set to false, User have to pass subnet id"
  default     = true
}

variable "vpc_cidr_block" {
  description = "Primary CIDR block for the VPC."
}

variable "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks for the Public Subnets inside the VPC."
  default     = []
}

variable "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks for the Private Subnets inside the VPC."
  default     = []
}

variable "azs" {
  description = "List of availability zones in the region."
  default     = []
}

#Application Nodes
variable "number_of_application_nodes_required" {
  default     = 2
}

variable "subnet_id_for_application_node" {
  description = "If network creation set to false, user has to pass the subnet id"
  default = ""
}

variable "ami_id" {
  description = "If network creation set to false, user has to pass the subnet id"
}

variable "subnet_id" {
  description = "If network creation set to false, user has to pass the subnet id"
  default = ""
}


variable "instance_type" {

}
variable "create_application_node" {
  default = true

}

variable "resource_name_prefix" {

}
variable "Source_Machine_Public_IP" {
  description = "From which source do you want to access NGINX. "
}

variable "terraform_machine_public_ip" {
  description = "Terraform machine Public IP Used for remote-exec"
}



