#Create SSH key set.. 
resource "tls_private_key" "key" {

  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "aws_key_pair" "generated_key" {

  key_name   = var.resource_name_prefix
  public_key = tls_private_key.key.public_key_openssh

}

#Create Security Group
resource "aws_security_group" "application" {

  name          = format("%s-%s", var.resource_name_prefix, "APPLICATION_NODE")
  vpc_id        = local.vpc_id
  ingress {
    description       = "22 access for Nginx server"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    security_groups = [aws_security_group.nginx.id]
  }
  
    ingress {
    description       = "8484 application port access for Nginx server "
    from_port         = 8484
    to_port           = 8484
    protocol          = "tcp"
    security_groups = [aws_security_group.nginx.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nginx" {

  name          = format("%s-%s", var.resource_name_prefix, "NGINX")
  vpc_id        = local.vpc_id
  ingress {
    description = "Allow 22 for Source Machine IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.Source_Machine_Public_IP
  }

    ingress {
    description = "Allow 80 for Source Machine IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.Source_Machine_Public_IP
  }
  
    ingress {
    description = "Terraform Box Public IP for remote-exec"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.terraform_machine_public_ip
  }
  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Template Data for Userdata Scripts 
data "template_file" "userdata" {
  template = file(
    "${path.module}/files/userdata/pre_softwares_install.sh",
	)
	vars = {
	  region  = var.region,
	      }
}


# Cloudinit Config for Userdata Scripts 
data "template_cloudinit_config" "userdata_cloud_init" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.userdata.rendered
  }
}


#Create application nodes
resource "aws_instance" "application_nodes" {
  depends_on = [aws_route.private_nat_gateway]
  count                       = var.create_application_node ? var.number_of_application_nodes_required : 0

  subnet_id                   = join("", aws_subnet.private.*.id)
  ami                         = var.ami_id
  vpc_security_group_ids      = [aws_security_group.application.id]
  key_name                    = aws_key_pair.generated_key.key_name
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.this.name
  user_data                   = data.template_cloudinit_config.userdata_cloud_init.rendered

  tags                        = merge({"Name" = format("%s-%s", var.resource_name_prefix, "APPLICATION_NODE"), "AppCode" = "APPLICATION-NODE"})
}

resource "aws_instance" "nginx" {
  depends_on = [aws_route.private_nat_gateway]

  subnet_id                   = join("", aws_subnet.public.*.id)
  ami                         = var.ami_id
  vpc_security_group_ids      = [aws_security_group.nginx.id]
  key_name                    = aws_key_pair.generated_key.key_name
  instance_type               = var.instance_type
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.this.name
  tags                        = merge({"Name" = format("%s-%s", var.resource_name_prefix, "MAIN-NGINX")})

}

resource "null_resource" "nginx_setup" {
 
  depends_on = [aws_instance.nginx]

  triggers = {
    runwhenIPChanged        = local.app_node_ips
	  runWhenWebNodeIPChanged = aws_instance.nginx.public_ip
  }

  connection {
    type        = "ssh"
    host        = aws_instance.nginx.public_ip 
    user        = "ec2-user"
    private_key = tls_private_key.key.private_key_pem
    port        = "22"
    timeout     = "60m"
    agent       = false
  }

  //Create installdb Directory
  provisioner "remote-exec" {
    inline = [
      "echo \"Create install Directory\"",
      "sudo mkdir /nginx",
      "sudo chmod 777 /nginx/"
    ]
  }

  // Copy setup script
  provisioner "file" {
    source      = "${path.module}/files/configure_load_balancer.sh"
    destination = "/nginx/configure_load_balancer.sh"
  }


  // Execute Load Balancer Setup scripts
  provisioner "remote-exec" {
    inline = [
	  "sudo chmod 777 /nginx/configure_load_balancer.sh",
      "sudo /nginx/configure_load_balancer.sh ${aws_instance.application_nodes[0].private_ip} ${aws_instance.application_nodes[1].private_ip}"   
    ]
  }
}



