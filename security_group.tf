locals {
  create_security_group = var.create_security_group && var.create_cluster ? true : false
}
