# aws_db_subnet_group
output "db_subnet_group_name" {
  description = "The db subnet group name"
  value       = local.db_subnet_group_name
}

# aws_rds_cluster
output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value       = try(aws_rds_cluster.aurora_database[0].arn, "")
}

output "cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = try(aws_rds_cluster.aurora_database[0].id, "")
}

output "cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value       = try(aws_rds_cluster.aurora_database[0].cluster_resource_id, "")
}

output "cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  value       = try(aws_rds_cluster.aurora_database[0].cluster_members, "")
}

output "cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = try(aws_rds_cluster.aurora_database[0].endpoint, "")
}

output "cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = try(aws_rds_cluster.aurora_database[0].reader_endpoint, "")
}

output "cluster_engine_version_actual" {
  description = "The running version of the cluster database"
  value       = try(aws_rds_cluster.aurora_database[0].engine_version_actual, "")
}

# database_name is not set on `aws_rds_cluster` resource if it was not specified, so can't be used in output
output "cluster_database_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = var.database_name
}

output "cluster_port" {
  description = "The database port"
  value       = try(aws_rds_cluster.aurora_database[0].port, "")
}

output "cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint"
  value       = try(aws_rds_cluster.aurora_database[0].hosted_zone_id, "")
}

# aws_rds_cluster_instances
output "cluster_instances" {
  description = "A map of cluster instances and their attributes"
  value       = aws_rds_cluster_instance.aurora_database
}

# aws_rds_cluster_endpoint
output "additional_cluster_endpoints" {
  description = "A map of additional cluster endpoints and their attributes"
  value       = aws_rds_cluster_endpoint.cluster_endpoint
}

# aws_rds_cluster_role_association
output "cluster_role_associations" {
  description = "A map of IAM roles associated with the cluster and their attributes"
  value       = aws_rds_cluster_role_association.cluster_role
}

# Enhanced monitoring role
output "enhanced_monitoring_iam_role_name" {
  description = "The name of the enhanced monitoring role"
  value       = try(aws_iam_role.rds_enhanced_monitoring[0].name, "")
}

output "enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the enhanced monitoring role"
  value       = try(aws_iam_role.rds_enhanced_monitoring[0].arn, "")
}

output "enhanced_monitoring_iam_role_unique_id" {
  description = "Stable and unique string identifying the enhanced monitoring role"
  value       = try(aws_iam_role.rds_enhanced_monitoring[0].unique_id, "")
}

output "security_group_id" {
  description = "The security groups ID of the instances"
  value       = module.security_group.security_group_id
}
