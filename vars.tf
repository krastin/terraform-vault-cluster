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



######################
## TLS variables     #
######################

# inspired by https://github.com/gruntwork-io/private-tls-cert

variable "organization_name" {
  description = "The name of the organization to associate with the certificates (e.g. Acme Co)."
  default = "Acme Co"
}

variable "ca_common_name" {
  description = "The common name to use in the subject of the CA certificate (e.g. acme.co cert)."
  default = "acme.co cert"
}

variable "validity_period_hours" {
  description = "The number of hours after initial issuing that the certificate will become invalid."
  default = "8765"
}

# OPTIONAL PARAMETERS

variable "ca_allowed_uses" {
  description = "List of keywords from RFC5280 describing a use that is permitted for the CA certificate. For more info and the list of keywords, see https://www.terraform.io/docs/providers/tls/r/self_signed_cert.html#allowed_uses."
  type        = list(string)

  default = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]
}

variable "allowed_uses" {
  description = "List of keywords from RFC5280 describing a use that is permitted for the issued certificate. For more info and the list of keywords, see https://www.terraform.io/docs/providers/tls/r/self_signed_cert.html#allowed_uses."
  type        = list(string)

  default = [
    "key_encipherment",
    "digital_signature",
  ]
}

variable "private_key_algorithm" {
  description = "The name of the algorithm to use for private keys. Must be one of: RSA or ECDSA."
  default     = "ECDSA"
}

variable "private_key_ecdsa_curve" {
  description = "The name of the elliptic curve to use. Should only be used if var.private_key_algorithm is ECDSA. Must be one of P224, P256, P384 or P521."
  default     = "P256"
}

variable "private_key_rsa_bits" {
  description = "The size of the generated RSA key in bits. Should only be used if var.private_key_algorithm is RSA."
  default     = "2048"
}
