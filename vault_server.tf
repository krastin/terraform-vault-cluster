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
      # install consul binary
      "sudo -H -u consul -s env VERSION='${var.consul_version}' /home/consul/install_consul.sh",

      # set up the first #consul_servers amount of nodes as SERVER=true and as bootstrap-expect as the amount of server nodes
      "sudo -H -u consul -s env RETRYIPS='${jsonencode(slice(var.consul_server_ips, 0, length(var.consul_server_ips)))}' SERVER='${count.index < length(var.consul_server_ips) ? "true" : "false"}' BOOTSTRAP='${length(var.consul_server_ips)}' /home/consul/configure_consul.sh",

      # test auto-join
      "sudo rm /etc/consul.d/retry_join.json",
      #"echo -e 'retry_join = [\"provider=aws tag_key=CLUSTER tag_value=CONSUL\"]' | sudo tee /etc/consul.d/cloud_join.hcl",
      "echo 'retry_join = [\"provider=aws tag_key=CLUSTER tag_value=CONSUL access_key_id=${var.consul-autojoin-keyid} secret_access_key=${var.consul-autojoin-secretkey}\"]' | sudo tee /etc/consul.d/cloud_join.hcl",      

      # start up consul
      "sudo systemctl start consul",

      # configure Consul
      "NODE_NAME=consul01 \
      ACCESS_KEY_ID=${var.consul-autojoin-keyid} \
      SECRET_ACCESS_KEY=${var.consul-autojoin-secretkey} \
      CLUSTER=CONSUL \
      bash /home/vault/configure_consul.sh",

      # configure vault
      "AWS_REGION='${var.aws_region}' \
      KMS_KEY='${aws_kms_key.vault.id}' \
      bash /home/vault/configure_vault.sh"
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

    owners = ["729476260648"]
}