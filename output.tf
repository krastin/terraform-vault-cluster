output "CONSUL_NODE_IPS" {
  value = join(",", concat(aws_instance.consul-server.*.public_ip))
  description = "all consul node IPs"
  sensitive = false
}

output "VAULT_NODE_IPS" {
  value = join(",", concat(aws_instance.vault-server.*.public_ip))
  description = "all vault node IPs"
  sensitive = false
}