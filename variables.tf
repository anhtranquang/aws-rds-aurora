################################################################################
# RDS Aurora Variables 
################################################################################

variable "create_cluster" {
  default     = true
  type        = bool
  description = "A boolean flag to determine whether to create RDS"
}

variable "master_username" {
  type        = string
  default     = "admin"
  description = "Master database username"
}

variable "cluster_identifier" {
  type        = string
  default     = ""
  description = "The RDS Cluster Identifier. Will use generated label ID if not supplied"
}

# aws_db_subnet_group
variable "create_db_subnet_group" {
  description = "Determines whether to create the database subnet group or use existing"
  type        = bool
  default     = true
}

variable "db_subnet_group_name" {
  description = "The name of the subnet group name (existing or created)"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "A list of subnets to assign to database subnet group. e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f']"
  type        = any
  default     = []
}

variable "create_db_parameter_group" {
  description = "Determines whether to create the databae parameter group or use existing"
  type        = bool
  default     = true
}

variable "cluster_family" {
  type        = string
  default     = null
  description = "The family of the DB cluster parameter group"
}

variable "parameter_group_name" {
  description = "The name of the DB parameter group to associate with instances"
  type        = string
  default     = null
}

variable "parameter_group" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default     = []
  description = "List parameter of database parameters group to apply"
}

variable "create_db_cluster_parameter_group" {
  description = "Determines whether to create the databae cluster parameter group or use existing"
  type        = bool
  default     = true
}

variable "db_cluster_parameter_group_name" {
  description = "A cluster parameter group to associate with the cluster"
  type        = string
  default     = null
}

variable "cluster_parameter_group" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default = [
    {
      apply_method = "immediate"
      name         = "log_statement"
      value        = "all"
    },
    {
      apply_method = "immediate"
      name         = "log_min_duration_statement"
      value        = "2000"
    }
  ]
  description = "List parameter of database cluster parameters group to apply"
}

variable "is_primary_cluster" {
  description = "Determines whether cluster is primary cluster with writer instance (set to `false` for global cluster and replica clusters)"
  type        = bool
  default     = true
}

variable "global_cluster_identifier" {
  description = "The global cluster identifier specified on `aws_rds_global_cluster`"
  type        = string
  default     = null
}

variable "enable_global_write_forwarding" {
  description = "Whether cluster should forward writes to an associated global cluster. Applied to secondary clusters to enable them to forward writes to an `aws_rds_global_cluster`'s primary cluster"
  type        = bool
  default     = null
}

variable "replication_source_identifier" {
  description = "ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica"
  type        = string
  default     = null
}

variable "source_region" {
  description = "The source region for an encrypted replica DB cluster"
  type        = string
  default     = null
}

variable "engine" {
  description = "The name of the database engine to be used for this DB cluster. Defaults to `aurora`. Valid Values: `aurora`, `aurora-mysql`, `aurora-postgresql`"
  type        = string
  default     = null
}

variable "engine_mode" {
  description = "The database engine mode. Valid values: `global`, `multimaster`, `parallelquery`, `provisioned`, `serverless`. Defaults to: `provisioned`"
  type        = string
  default     = null
}

variable "engine_version" {
  description = "The database engine version. Updating this argument results in an outage"
  type        = string
  default     = null
}

variable "allow_major_version_upgrade" {
  description = "Enable to allow major engine version upgrades when changing engine versions. Defaults to `false`"
  type        = bool
  default     = false
}

variable "enable_http_endpoint" {
  description = "Enable HTTP endpoint (data API). Only valid when engine_mode is set to `serverless`"
  type        = bool
  default     = null
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying `kms_key_id`, `storage_encrypted` needs to be set to `true`"
  type        = string
  default     = null
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation"
  type        = string
  default     = null
}

variable "final_snapshot_identifier_prefix" {
  description = "The prefix name to use when creating a final snapshot on cluster destroy; a 8 random digits are appended to name to ensure it's unique"
  type        = string
  default     = "final"
}

variable "skip_final_snapshot" {
  description = "Determines whether a final snapshot is created before the cluster is deleted. If true is specified, no snapshot is created"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`. The default is `false`"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "The days to retain backups for. Default `7`"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled using the `backup_retention_period` parameter. Time in UTC"
  type        = string
  default     = "02:00-03:00"
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in (UTC)"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate to the cluster in addition to the SG we create in this module"
  type        = list(string)
  default     = []
}

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot"
  type        = string
  default     = null
}

variable "storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted. The default is `true`"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is `false`"
  type        = bool
  default     = false
}

variable "db_cluster_db_instance_parameter_group_name" {
  description = "Instance parameter group to associate with all instances of the DB cluster. The `db_cluster_db_instance_parameter_group_name` is only valid in combination with `allow_major_version_upgrade`"
  type        = string
  default     = null
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  type        = bool
  default     = false
}

variable "backtrack_window" {
  description = "The target backtrack window, in seconds. Only available for `aurora` engine currently. To disable backtracking, set this value to 0. Must be between 0 and 259200 (72 hours)"
  type        = number
  default     = null
}

variable "copy_tags_to_snapshot" {
  description = "Copy all Cluster `tags` to snapshots"
  type        = bool
  default     = false
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: `audit`, `error`, `general`, `slowquery`, `postgresql`"
  type        = list(string)
  default     = []
}

variable "cluster_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster"
  type        = map(string)
  default     = {}
}

variable "scaling_configuration" {
  description = "Map of nested attributes with scaling properties. Only valid when `engine_mode` is set to `serverless`"
  type        = map(string)
  default     = {}
}

variable "serverlessv2_scaling_configuration" {
  description = "Map of nested attributes with serverless v2 scaling properties. Only valid when `engine_mode` is set to `provisioned`"
  type        = map(string)
  default     = {}
}

variable "s3_import" {
  description = "Configuration map used to restore from a Percona Xtrabackup in S3 (only MySQL is supported)"
  type        = map(string)
  default     = null
}

variable "restore_to_point_in_time" {
  description = "Map of nested attributes for cloning Aurora cluster"
  type        = map(string)
  default     = {}
}

variable "cluster_tags" {
  description = "A map of tags to add to only the cluster. Used for AWS Instance Scheduler tagging"
  type        = map(string)
  default     = {}
}

# aws_rds_cluster_instances
variable "instances" {
  description = "Map of cluster instances and any specific/overriding attributes to be created"
  type        = any
  default     = {}
}

variable "instance_class" {
  description = "Instance type to use at master instance. Note: if `autoscaling_enabled` is `true`, this will be the same instance class used on instances created by autoscaling"
  type        = string
  default     = ""
}

variable "publicly_accessible" {
  description = "Determines whether instances are publicly accessible. Default false"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for instances. Set to `0` to disble. Default is `0`"
  type        = number
  default     = 0
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default `true`"
  type        = bool
  default     = true
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not"
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data"
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years)"
  type        = number
  default     = null
}

variable "ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance"
  type        = string
  default     = null
}

variable "instance_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster instance(s)"
  type        = map(string)
  default     = {}
}

# aws_rds_cluster_endpoint
variable "endpoints" {
  description = "Map of additional cluster endpoints and their attributes to be created"
  type        = any
  default     = {}
}

# aws_rds_cluster_role_association
variable "iam_roles" {
  description = "Map of IAM roles and supported feature names to associate with the cluster"
  type        = map(map(string))
  default     = {}
}

# Enhanced monitoring role
variable "create_monitoring_role" {
  description = "Determines whether to create the IAM role for RDS enhanced monitoring"
  type        = bool
  default     = true
}

variable "monitoring_role_arn" {
  description = "IAM role used by RDS to send enhanced monitoring metrics to CloudWatch"
  type        = string
  default     = ""
}

variable "iam_role_name" {
  description = "Friendly name of the monitoring role"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the monitoring role"
  type        = string
  default     = null
}

variable "iam_role_path" {
  description = "Path for the monitoring role"
  type        = string
  default     = null
}

variable "iam_role_managed_policy_arns" {
  description = "Set of exclusive IAM managed policy ARNs to attach to the monitoring role"
  type        = list(string)
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the monitoring role"
  type        = string
  default     = null
}

variable "iam_role_force_detach_policies" {
  description = "Whether to force detaching any policies the monitoring role has before destroying it"
  type        = bool
  default     = false
}

variable "iam_role_max_session_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the monitoring role"
  type        = number
  default     = null
}

# aws_appautoscaling_*
variable "autoscaling_enabled" {
  description = "Determines whether autoscaling of the cluster read replicas is enabled"
  type        = bool
  default     = false
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of read replicas permitted when autoscaling is enabled"
  type        = number
  default     = 2
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of read replicas permitted when autoscaling is enabled"
  type        = number
  default     = 0
}

variable "predefined_metric_type" {
  description = "The metric type to scale on. Valid values are `RDSReaderAverageCPUUtilization` and `RDSReaderAverageDatabaseConnections`"
  type        = string
  default     = "RDSReaderAverageCPUUtilization"
}

variable "autoscaling_scale_in_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale in"
  type        = number
  default     = 300
}

variable "autoscaling_scale_out_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale out"
  type        = number
  default     = 300
}

variable "autoscaling_target_cpu" {
  description = "CPU threshold which will initiate autoscaling"
  type        = number
  default     = 70
}

variable "autoscaling_target_connections" {
  description = "Average number of connections threshold which will initiate autoscaling. Default value is 70% of db.r4/r5/r6g.large's default max_connections"
  type        = number
  default     = 700
}


################################################################################
# Security Variables
################################################################################

variable "create_security_group" {
  type        = bool
  default     = true
  description = "A boolean flag to determine whether to create Security Group."
}

variable "security_group_rules" {
  type = list(any)
  default = [
    {
      type                     = "egress"
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
      self                     = null
    }
  ]
  description = <<-EOT
    A list of maps of Security Group rules. 
    The values of map is fully complated with `aws_security_group_rule` resource. 
    To get more info see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule.
      {
        type                     = "ingress"
        from_port                = 443
        to_port                  = 443
        protocol                 = "tcp"
        cidr_blocks              = ["0.0.0.0/0"]
        source_security_group_id = null
        self                     = null
      },
  EOT
}

variable "security_group_extend_rules" {
  type        = list(any)
  default     = []
  description = <<-EOT
    A list of maps of Security Group rules. 
    The values of map is fully complated with `aws_security_group_rule` resource. 
    To get more info see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule.
    {
      type              = "ingress"
      from_port         = 6379
      to_port           = 6379
      protocol          = "tcp"
      cidr_blocks       = []
      security_group_id = "sg-123456789"
    }
  EOT
}

################################################################################
# Common Variables
################################################################################

variable "master_prefix" {
  description = "To specify a key prefix for aws resource"
  type        = string
  default     = "dso"
}

variable "subnet_tag" {
  description = "Tag Name of subnet to get list of subnets."
  type        = string
  default     = null
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC that the instance security group belongs to"
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS Region name to deploy resources."
  type        = string
  default     = "ap-southeast-1"
}

variable "assume_role" {
  description = "AssumeRole to manage the resources within account that owns"
  type        = string
  default     = null
  validation {
    condition     = can(regex("^arn:aws:iam::[[:digit:]]{12}:role/.+", var.assume_role))
    error_message = "Must be a valid AWS IAM role ARN."
  }
}

variable "secret_assume_role" {
  description = "AssumeRole to manage the resources within account containing secret manager."
  type        = string
  default     = null
}


################################################################################
# Route53 group
################################################################################

variable "create_dns" {
  default     = false
  type        = bool
  description = "A boolean flag to add record to route53"
}

variable "record_name" {
  type        = string
  description = "Route53 record name"
  default     = null
}

variable "dns_zone_id" {
  type        = string
  description = "Route53 parent zone ID."
  default     = null
}

variable "dns_zone_ttl" {
  type        = number
  default     = 60
  description = "The TTL of the record."
}

variable "recovery_window_in_days" {
  description = "(Optional) Number of days that AWS Secrets Manager waits before it can delete the secret. This value can be 0 to force deletion without recovery or range from 7 to 30 days. The default value is 0"
  type        = number
  default     = 0
}
