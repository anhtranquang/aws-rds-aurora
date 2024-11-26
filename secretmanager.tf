resource "random_password" "master_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "rds" {
  count                   = local.create_cluster ? 1 : 0
  name                    = format("%s/rds-master-cred/%s", var.master_prefix, var.cluster_identifier)
  recovery_window_in_days = var.recovery_window_in_days
  tags                    = var.tags
  provider                = aws.secret
  depends_on = [
    aws_rds_cluster.aurora_database,
  ]
}

resource "aws_secretsmanager_secret_version" "rds" {
  count     = local.create_cluster ? 1 : 0
  secret_id = aws_secretsmanager_secret.rds[0].id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master_password.result
  })
  provider = aws.secret
  depends_on = [
    aws_rds_cluster.aurora_database,
  ]
}
