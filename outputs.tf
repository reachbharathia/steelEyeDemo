output "Application_Nodes_IP" {
  description = "Application Nodes IP's"
  value       = local.app_node_ips
}

output "nginx_node_private_ip" {
  description = "Nginx Private IP"
  value       = aws_instance.nginx.private_ip
}

output "nginx_node_public_ip" {
  description = "Nginx Public IP"
  value       = aws_instance.nginx.public_ip
}

output "private_key" {
  description = "Private key to connect with instances."
  value       = tls_private_key.key.private_key_pem
}