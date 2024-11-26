locals {
  secret_assume_role = var.secret_assume_role == null || var.secret_assume_role == "" ? var.assume_role : var.secret_assume_role
  create_cluster     = var.create_cluster
  aurora_name        = format("%s-%s", var.master_prefix, var.cluster_identifier)
  port               = coalesce(var.port, (var.engine == "aurora-postgresql" ? 5432 : 3306))

  db_user_pass                    = random_password.master_password.result
  db_subnet_group_name            = try(coalesce(var.db_subnet_group_name, format("%s-sg", local.aurora_name)), "")
  db_cluster_parameter_group_name = try(coalesce(var.db_cluster_parameter_group_name, format("%s-cluster-pg", local.aurora_name)), "")
  db_parameter_group_name         = try(coalesce(var.parameter_group_name, format("%s-pg", local.aurora_name)), "")
  backtrack_window                = (var.engine == "aurora-mysql" || var.engine == "aurora") && var.engine_mode != "serverless" ? var.backtrack_window : 0
  rds_enhanced_monitoring_arn     = var.create_monitoring_role ? join("", aws_iam_role.rds_enhanced_monitoring.*.arn) : var.monitoring_role_arn
  is_serverless                   = var.engine_mode == "serverless"
  final_snapshot_identifier       = var.skip_final_snapshot ? null : "${var.final_snapshot_identifier_prefix}-${local.aurora_name}-${random_id.snapshot_identifier[0].hex}"
}
