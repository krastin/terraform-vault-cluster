######################
## Vault variables   #
######################

variable "vault_version" {
  default = "" # if no version passed then get newest OSS
}

variable "vault_ami_filter" {
  default = "krastin-xenial-vault-*"
}

variable "aws_ami_owner" {
  default = ""
}

variable "vault_license" {
  default = ""
}

variable "vault_server_ips" {
  default = [
    "10.1.0.11",
    "10.1.0.12",
    "10.1.0.13",
  ]
}

######################
## Consul variables  #
######################

variable "consul_version" {
  default = "" # if no version passed then get newest OSS
}

variable "consul_ami_filter" {
  default = "krastin-xenial-consul-*"
}

variable "consul_server_ips" {
  default = [
    "10.1.0.101",
    "10.1.0.102",
    "10.1.0.103",
  ]
}

variable "consul_license" {}
variable "consul-autojoin-keyid" {}
variable "consul-autojoin-secretkey" {}


######################
## AWS-VPC variables #
######################

variable "aws_profile" {
  default = ""
}
variable "aws_region" {
  default = "eu-central-1"
}

variable "aws_prefix" {
  default = "test"
}

variable "datacenter" {
  default = "dc1"
}

variable "cidr_block" {
  default = "10.1.0.0/16"
}

variable "owner" {
  default = "testuser@company.com"
}

variable "ssh_key" {
  default = "~/.ssh/id_rsa"
}

variable "instance_ssh_keyname" {} 

provider "aws" {
  profile    = var.aws_profile
  region     = var.aws_region
}