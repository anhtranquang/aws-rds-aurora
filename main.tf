resource "random_id" "snapshot_identifier" {
  count = local.create_cluster && !var.skip_final_snapshot ? 1 : 0

  keepers = {
    id = local.aurora_name
  }

  byte_length = 4
}

resource "aws_db_subnet_group" "aurora" {
  count       = local.create_cluster && var.create_db_subnet_group ? 1 : 0
  description = format("Database subnet group for Aurora cluster %s", local.aurora_name)
  subnet_ids  = length(var.subnet_ids) > 0 ? tolist(var.subnet_ids) : tolist(data.aws_subnets.selected.ids)
  name        = local.db_subnet_group_name
  tags        = var.tags
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  count       = local.create_cluster && var.create_db_cluster_parameter_group ? 1 : 0
  description = format("Database cluster parameter group for Aurora cluster %s", local.aurora_name)
  family      = var.cluster_family
  name        = local.db_cluster_parameter_group_name

  dynamic "parameter" {
    for_each = var.cluster_parameter_group
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = lookup(parameter.value, "name", null)
      value        = lookup(parameter.value, "value", null)
    }
  }
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "aurora" {
  count       = local.create_cluster && var.create_db_parameter_group ? 1 : 0
  description = format("Database parameter group for Aurora cluster %s", local.aurora_name)
  family      = var.cluster_family
  name        = local.db_parameter_group_name

  dynamic "parameter" {
    for_each = var.parameter_group
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = lookup(parameter.value, "name", null)
      value        = lookup(parameter.value, "value", null)
    }
  }
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster" "aurora_database" {
  count = local.create_cluster ? 1 : 0

  global_cluster_identifier      = var.global_cluster_identifier
  enable_global_write_forwarding = var.enable_global_write_forwarding
  cluster_identifier             = local.aurora_name
  replication_source_identifier  = var.replication_source_identifier
  source_region                  = var.source_region

  engine                              = var.engine
  engine_mode                         = var.engine_mode
  engine_version                      = local.is_serverless ? null : var.engine_version
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  enable_http_endpoint                = var.enable_http_endpoint
  kms_key_id                          = var.kms_key_id
  database_name                       = var.is_primary_cluster ? var.database_name : null
  master_username                     = var.is_primary_cluster ? var.master_username : null
  master_password                     = var.is_primary_cluster ? local.db_user_pass : null
  final_snapshot_identifier           = local.final_snapshot_identifier
  skip_final_snapshot                 = var.skip_final_snapshot
  deletion_protection                 = var.deletion_protection
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = local.is_serverless ? null : var.preferred_backup_window
  preferred_maintenance_window        = local.is_serverless ? null : var.preferred_maintenance_window
  port                                = local.port
  db_subnet_group_name                = local.db_subnet_group_name
  vpc_security_group_ids              = compact(flatten([module.security_group.security_group_id, var.vpc_security_group_ids]))
  snapshot_identifier                 = var.snapshot_identifier
  storage_encrypted                   = var.storage_encrypted
  apply_immediately                   = var.apply_immediately
  db_cluster_parameter_group_name     = local.db_cluster_parameter_group_name
  db_instance_parameter_group_name    = var.allow_major_version_upgrade ? var.db_cluster_db_instance_parameter_group_name : null
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  backtrack_window                    = local.backtrack_window
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports

  timeouts {
    create = lookup(var.cluster_timeouts, "create", null)
    update = lookup(var.cluster_timeouts, "update", null)
    delete = lookup(var.cluster_timeouts, "delete", null)
  }

  dynamic "scaling_configuration" {
    for_each = length(keys(var.scaling_configuration)) == 0 || !local.is_serverless ? [] : [var.scaling_configuration]

    content {
      auto_pause               = lookup(scaling_configuration.value, "auto_pause", null)
      max_capacity             = lookup(scaling_configuration.value, "max_capacity", null)
      min_capacity             = lookup(scaling_configuration.value, "min_capacity", null)
      seconds_until_auto_pause = lookup(scaling_configuration.value, "seconds_until_auto_pause", null)
      timeout_action           = lookup(scaling_configuration.value, "timeout_action", null)
    }
  }

  dynamic "serverlessv2_scaling_configuration" {
    for_each = length(keys(var.serverlessv2_scaling_configuration)) == 0 || local.is_serverless ? [] : [var.serverlessv2_scaling_configuration]

    content {
      max_capacity = serverlessv2_scaling_configuration.value.max_capacity
      min_capacity = serverlessv2_scaling_configuration.value.min_capacity
    }
  }
  dynamic "s3_import" {
    for_each = var.s3_import != null && !local.is_serverless ? [var.s3_import] : []
    content {
      source_engine         = "mysql"
      source_engine_version = s3_import.value.source_engine_version
      bucket_name           = s3_import.value.bucket_name
      bucket_prefix         = lookup(s3_import.value, "bucket_prefix", null)
      ingestion_role        = s3_import.value.ingestion_role
    }
  }

  dynamic "restore_to_point_in_time" {
    for_each = length(keys(var.restore_to_point_in_time)) == 0 ? [] : [var.restore_to_point_in_time]

    content {
      source_cluster_identifier  = restore_to_point_in_time.value.source_cluster_identifier
      restore_type               = lookup(restore_to_point_in_time.value, "restore_type", null)
      use_latest_restorable_time = lookup(restore_to_point_in_time.value, "use_latest_restorable_time", null)
      restore_to_time            = lookup(restore_to_point_in_time.value, "restore_to_time", null)
    }
  }

  lifecycle {
    ignore_changes = [
      replication_source_identifier,
      global_cluster_identifier,
    ]
  }

  tags = merge(var.tags, var.cluster_tags)
}

resource "aws_rds_cluster_instance" "aurora_database" {
  for_each = local.create_cluster && !local.is_serverless ? var.instances : {}

  identifier                            = lookup(each.value, "identifier", "${local.aurora_name}-${each.key}")
  cluster_identifier                    = try(aws_rds_cluster.aurora_database[0].id, "")
  engine                                = var.engine
  engine_version                        = var.engine_version
  instance_class                        = lookup(each.value, "instance_class", var.instance_class)
  publicly_accessible                   = lookup(each.value, "publicly_accessible", var.publicly_accessible)
  db_subnet_group_name                  = local.db_subnet_group_name
  db_parameter_group_name               = local.db_parameter_group_name
  apply_immediately                     = lookup(each.value, "apply_immediately", var.apply_immediately)
  monitoring_role_arn                   = local.rds_enhanced_monitoring_arn
  monitoring_interval                   = lookup(each.value, "monitoring_interval", var.monitoring_interval)
  promotion_tier                        = lookup(each.value, "promotion_tier", null)
  availability_zone                     = lookup(each.value, "availability_zone", null)
  preferred_maintenance_window          = lookup(each.value, "preferred_maintenance_window", var.preferred_maintenance_window)
  auto_minor_version_upgrade            = lookup(each.value, "auto_minor_version_upgrade", var.auto_minor_version_upgrade)
  performance_insights_enabled          = lookup(each.value, "performance_insights_enabled", var.performance_insights_enabled)
  performance_insights_kms_key_id       = lookup(each.value, "performance_insights_kms_key_id", var.performance_insights_kms_key_id)
  performance_insights_retention_period = lookup(each.value, "performance_insights_retention_period", var.performance_insights_retention_period)
  copy_tags_to_snapshot                 = lookup(each.value, "copy_tags_to_snapshot", var.copy_tags_to_snapshot)
  ca_cert_identifier                    = var.ca_cert_identifier

  timeouts {
    create = lookup(var.instance_timeouts, "create", null)
    update = lookup(var.instance_timeouts, "update", null)
    delete = lookup(var.instance_timeouts, "delete", null)
  }

  tags = var.tags
}

resource "aws_rds_cluster_endpoint" "cluster_endpoint" {
  for_each = local.create_cluster && !local.is_serverless ? var.endpoints : tomap({})

  cluster_identifier          = try(aws_rds_cluster.aurora_database[0].id, "")
  cluster_endpoint_identifier = each.value.identifier
  custom_endpoint_type        = each.value.type

  static_members   = lookup(each.value, "static_members", null)
  excluded_members = lookup(each.value, "excluded_members", null)

  depends_on = [
    aws_rds_cluster_instance.aurora_database
  ]

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

resource "aws_rds_cluster_role_association" "cluster_role" {
  for_each = local.create_cluster ? var.iam_roles : {}

  db_cluster_identifier = try(aws_rds_cluster.aurora_database[0].id, "")
  feature_name          = each.value.feature_name
  role_arn              = each.value.role_arn
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = local.create_cluster && var.create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0

  name        = var.iam_role_name
  description = var.iam_role_description
  path        = var.iam_role_path

  assume_role_policy    = data.aws_iam_policy_document.monitoring_rds_assume_role.json
  managed_policy_arns   = var.iam_role_managed_policy_arns
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = var.iam_role_force_detach_policies
  max_session_duration  = var.iam_role_max_session_duration

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = local.create_cluster && var.create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
