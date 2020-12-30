# ---------------------------------------------------------------------------------------------------------------------
#  CREATE A CA CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "ca" {
  algorithm   = var.private_key_algorithm
  ecdsa_curve = var.private_key_ecdsa_curve
  rsa_bits    = var.private_key_rsa_bits
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm     = tls_private_key.ca.algorithm
  private_key_pem   = tls_private_key.ca.private_key_pem
  is_ca_certificate = true

  validity_period_hours = var.validity_period_hours
  allowed_uses          = var.ca_allowed_uses

  subject {
    common_name  = var.ca_common_name
    organization = var.organization_name
  }

  # CA Certificate Value: ${tls_self_signed_cert.ca.cert_pem}
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A TLS CERTIFICATE SIGNED USING THE CA CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "cert" {
  count       = length(var.vault_server_ips)
  algorithm   = var.private_key_algorithm
  ecdsa_curve = var.private_key_ecdsa_curve
  rsa_bits    = var.private_key_rsa_bits

  # TLS Certificate private key Value: ${tls_private_key.cert[0].private_key_pem}
}

resource "tls_cert_request" "cert" {
  count           = length(var.vault_server_ips)
  key_algorithm   = tls_private_key.cert[count.index].algorithm
  private_key_pem = tls_private_key.cert[count.index].private_key_pem

  dns_names    = ["${aws_instance.vault-server[count.index].public_dns}"]
  ip_addresses = ["${aws_instance.vault-server[count.index].public_ip}", "${aws_instance.vault-server[count.index].private_ip}"]

  subject {
    common_name  = aws_instance.vault-server[count.index].public_dns
    organization = var.organization_name
  }
}

resource "tls_locally_signed_cert" "cert" {
  count            = length(var.vault_server_ips)
  cert_request_pem = tls_cert_request.cert[count.index].cert_request_pem
  ca_key_algorithm   = tls_private_key.ca.algorithm
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = var.validity_period_hours
  allowed_uses          = var.allowed_uses

  # TLS Certificate public key Value: ${tls_locally_signed_cert.cert[0].cert_pem}
}



resource "null_resource" "tls_certificates" {
  count = length(var.vault_server_ips)
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    vault_node_addresses = join(",", aws_instance.vault-server.*.public_ip)
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = aws_instance.vault-server[count.index].public_ip
    type = "ssh"
    user = "ubuntu"
    agent = false
    private_key = file(var.ssh_key)
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      # provision certificates
      "echo '${tls_self_signed_cert.ca.cert_pem}' > /tmp/vault_ca.pem",
      "echo '${tls_private_key.cert[count.index].private_key_pem}' > /tmp/vault_privatekey.pem",
      "echo '${tls_locally_signed_cert.cert[count.index].cert_pem}' > /tmp/vault_publickey.pem",
      "sudo chmod 600 /tmp/vault_ca.pem /tmp/vault_privatekey.pem /tmp/vault_publickey.pem",
      "sudo chown vault /tmp/vault_ca.pem /tmp/vault_privatekey.pem /tmp/vault_publickey.pem",
      "sudo mv /tmp/vault_*.pem /home/vault/",
      "sudo sed -i -e '/listener/,+4d' /etc/vault.d/vault.hcl",
      "sudo echo \"listener \\\"tcp\\\" {\n  address     = \\\"0.0.0.0:8200\\\"\n  tls_cert_file = \\\"/home/vault/vault_publickey.pem\\\"\n  tls_key_file  = \\\"/home/vault/vault_privatekey.pem\\\"\n}\n\" > /etc/vault.d/listener.hcl",
    ]
  }
}
