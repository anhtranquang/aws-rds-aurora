locals {
  create_security_group = var.create_security_group && var.create_cluster ? true : false
}

module "security_group" {
  source                      = "git::https://github.com/GalaxyFinX/aws-security-group.git?ref=v1.1.0"
  name_security_group         = var.cluster_identifier
  security_group_rules        = var.security_group_rules
  security_group_extend_rules = var.security_group_extend_rules
  vpc_id                      = var.vpc_id
  tags                        = var.tags
  master_prefix               = var.master_prefix
  create_security_group       = local.create_security_group
  aws_region                  = var.aws_region
  assume_role                 = var.assume_role
}
