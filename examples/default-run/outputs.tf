output "nginx_node_public_ip" {
  description = "Nginx Public IP"
  value       = module.default_run.nginx_node_public_ip
}