data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "vault-kms-unseal" {
  statement {
    sid       = "VaultKMSUnseal"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
  }
}

resource "aws_iam_role" "vault-kms-unseal" {
  name               = "${var.aws_prefix}-${var.datacenter}-iam_role-vault_kms_unseal"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "vault-kms-unseal" {
  name   = "${var.aws_prefix}-${var.datacenter}-iam_role_policy-vault_kms_unseal"
  role   = aws_iam_role.vault-kms-unseal.id
  policy = data.aws_iam_policy_document.vault-kms-unseal.json
}

resource "aws_iam_instance_profile" "vault-kms-unseal" {
  name = "${var.aws_prefix}-${var.datacenter}-iam_instance_profile-vault_kms_unseal"
  role = aws_iam_role.vault-kms-unseal.name
}

resource "aws_kms_key" "vault" {
  description             = "Vault unseal key"
  deletion_window_in_days = 10

  tags = {
    Owner = var.owner
    # Keep  = ""
    Name = "${var.aws_prefix}-${var.datacenter}-vault-kms_key-unseal"
  }
}
