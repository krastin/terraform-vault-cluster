resource "aws_instance" "consul-server" {
  count = length(var.consul_server_ips)
  ami = data.aws_ami.ami-consul-server.id
  instance_type = "m5.large"
  private_ip = var.consul_server_ips[count.index]

  vpc_security_group_ids = ["${aws_security_group.secgrp-permit.id}"]
  subnet_id = aws_subnet.subnet-vaultcluster.id

  provisioner "remote-exec" {
    inline = [
      "sudo -H -u consul -s env SERVER='true' NODE_NAME=consul${count.index} BOOTSTRAP='${length(var.consul_server_ips)}' ACCESS_KEY_ID='${var.consul-autojoin-keyid}' SECRET_ACCESS_KEY='${var.consul-autojoin-secretkey}' CLUSTER=CONSUL bash /home/consul/configure_consul.sh",
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
    Name = "${var.aws_prefix}-${var.datacenter}-consul-server.${count.index}"
    CLUSTER = "CONSUL"
    Datacenter = var.datacenter
  }
}

data "aws_ami" "ami-consul-server" {
    most_recent = true

    filter {
        name   = "name"
        values = ["${var.consul_ami_filter}"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["${var.aws_ami_owner}"]
}
