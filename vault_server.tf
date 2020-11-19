resource "aws_instance" "vault-server" {
  depends_on = [
    aws_instance.consul-server,
  ]
  count = length(var.vault_server_ips)
  ami = data.aws_ami.ami-vault-server.id
  instance_type = "m5.large"
  private_ip = var.vault_server_ips[count.index]

  associate_public_ip_address = true
  ebs_optimized               = false
  iam_instance_profile        = aws_iam_instance_profile.vault-kms-unseal.id

  vpc_security_group_ids = ["${aws_security_group.secgrp-permit.id}"]
  subnet_id = aws_subnet.subnet-vaultcluster.id

  provisioner "remote-exec" {
    inline = [
      # configure Consul
      "sudo -H -u consul -s env SERVER='false' NODE_NAME=consul${count.index} ACCESS_KEY_ID='${var.consul-autojoin-keyid}' SECRET_ACCESS_KEY='${var.consul-autojoin-secretkey}' CLUSTER=CONSUL bash /home/consul/configure_consul.sh",

      # configure vault
      "sudo -H -u vault -s env VAULT_LICENSE='${var.vault_license}' AWS_REGION='${var.aws_region}' KMS_KEY='${aws_kms_key.vault.id}' bash /home/vault/configure_vault.sh"
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      agent = false
      host = self.public_ip
      private_key = file(var.ssh_key)
    }
  }

  key_name = var.instance_ssh_keyname

  tags = {
    Owner = var.owner
    # Keep  = ""
    Name = "${var.aws_prefix}-${var.datacenter}-vault-server.${count.index}"
    CLUSTER = "CONSUL"
    Datacenter = var.datacenter
  }
}

data "aws_ami" "ami-vault-server" {
    most_recent = true

    filter {
        name   = "name"
        values = ["${var.vault_ami_filter}"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["${var.aws_ami_owner}"]
}