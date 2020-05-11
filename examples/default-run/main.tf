module "default_run" {
  source = "../../"                        
								           
  region                               = var.region
  access_key                           = var.access_key
  secret_key                           = var.secret_key
  token                                = var.token
							          
  #Networking                         
  vpc_cidr_block                       = var.vpc_cidr_block
  public_subnet_cidr_blocks            = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks           = var.private_subnet_cidr_blocks
  azs                                  = var.azs 
  
  #Application Nodes
  resource_name_prefix                 = var.resource_name_prefix
  ami_id                               = var.ami_id
  instance_type                        = var.instance_type
  bucket_name                          = var.bucket_name
  Source_Machine_Public_IP             = var.Source_Machine_Public_IP
  terraform_machine_public_ip          = var.terraform_machine_public_ip

}

