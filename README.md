#  How To Use
<This code will run only Linux Machine>
<This code written in Terarform 0.12 format>
1. Clone the master repo. 
2. Go to Examples -> Default-run
3. Open default_run.auto.tfvars file. 

```
      - Update below Variable values
          - access_key                 = "Access_Key"
          - secret_key                 = "Secret_Key"
          - token                      = "Token"
          - vpc_cidr_block             = "10.248.50.0/23"        #Example_Value
          - public_subnet_cidr_blocks  = ["10.248.50.0/25"]      #Example_Value
          - private_subnet_cidr_blocks = ["10.248.51.0/25"]      #Example_Value
          - azs                        = ["us-east-1a"]          #Example_Value
          - resource_name_prefix       = "steelEye-Project-test" #Example_Value
          - bucket_name                = "steelEye-Project-test" #Example_Value
          - Source_Machine_Public_IP   = ["52.202.117.177/32"]   #Example_Value
          - terraform_machine_public_ip= ["52.55.2.79/32"]       #Example_Value
```
4. Terraform init
5. Terraform plan
6. Terraform apply -auto-approve
7. In output you can see Nginx server public IP. 
8. Login into Source Machine (here ->Source_Machine_Public_IP). 
9. Open the powershell and run this command curl://Nginx_Public_ip. Run multiple time and see traffic will switch between the application servers and nginx using Round Robin Load Balancing method as default. 

## Variable
```
Source_Machine_Public_IP : 
	- From this source machine i can access nginx server public IP, 
	    - example i can do curl http://nginx_public_ip
		  - example i can connect nginx server by 22 port. (In state file search "private_key", copy them and save it as .pem)
```
```
terraform_machine_public_ip :
    - Machine Where the terraform code is running. 
		- example in backend terraform using remote-exec to connect with Ngix server, so that terraform can do ngix configurations.
```

#  Module Usage  
```
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
```
#  auto.tfvars file  
```
region     = "us-east-1"
access_key = "access_key"
secret_key = "secret_key"
token      = "token"

vpc_cidr_block                       = "10.248.50.0/23"
public_subnet_cidr_blocks            = ["10.248.50.0/25"]
private_subnet_cidr_blocks           = ["10.248.51.0/25"]
azs                                  = ["us-east-1a"]

resource_name_prefix                 = "TEST"
ami_id                               = "ami-02a068f221799a400"
instance_type                        = "t2.medium"
bucket_name                          = "ba-test-d5ba01"
Source_Machine_Public_IP             = ["52.202.117.177/32"] #From this machine you access NGINX. To open 22 and 80  
terraform_machine_public_ip          = ["52.55.2.79/32"]     #Terraform machine Public IP Used for remote-exec. To open 22
```


These resources are included: 
* [Caller Identity](https://www.terraform.io/docs/providers/aws/d/caller_identity.html)
* [Security Group](https://www.terraform.io/docs/providers/aws/r/security_group.html)
* [Security Group](https://www.terraform.io/docs/providers/aws/r/security_group.html)
* [IAM Role](https://www.terraform.io/docs/providers/aws/r/iam_role.html)
* [IAM Policy](https://www.terraform.io/docs/providers/aws/r/iam_policy.html)
* [Codedeploy Application](https://www.terraform.io/docs/providers/aws/r/codedeploy_app.html)
* [Codedeploy Deployment Group](https://www.terraform.io/docs/providers/aws/r/codedeploy_deployment_group.html)
* [Codepipeline](https://www.terraform.io/docs/providers/aws/r/codepipeline.html)
* [S3 Bucket](https://www.terraform.io/docs/providers/aws/r/s3_bucket.html)
* [Null Resource](https://www.terraform.io/docs/providers/null/resource.html)
* [TLS Private Key](https://www.terraform.io/docs/providers/tls/r/private_key.html)
* [Key Pair](https://www.terraform.io/docs/providers/aws/r/key_pair.html)
* [VPC](https://www.terraform.io/docs/providers/aws/r/vpc.html)

