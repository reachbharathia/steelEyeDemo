region     = "us-east-1"
access_key = "access_key"
secret_key = "secret_key"
token      = "token"

vpc_cidr_block                       = "10.248.50.0/23"
public_subnet_cidr_blocks            = ["10.248.50.0/25"]
private_subnet_cidr_blocks           = ["10.248.51.0/25"]
azs                                  = ["us-east-1a"]

resource_name_prefix                 = "TEST"
ami_id                               = "ami-12345649"
instance_type                        = "t2.medium"
bucket_name                          = "ba-test-d5ba01"
Source_Machine_Public_IP             = ["52.202.117.177/32"] #From this machine you access NGINX. To open 22 and 80  
terraform_machine_public_ip          = ["52.55.2.79/32"]     #Terraform machine Public IP Used for remote-exec. To open 22