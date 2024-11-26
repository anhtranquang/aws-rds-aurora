locals {
  create_module_dns = local.create_cluster && var.create_dns ? 1 : 0
  record_name       = var.record_name != null ? var.record_name : var.cluster_identifier
}
resource "aws_route53_record" "aurora_dns" {
  count = local.create_module_dns
  depends_on = [
    aws_rds_cluster.aurora_database,
  ]
  allow_overwrite = true
  name            = local.record_name
  records = [
    aws_rds_cluster.aurora_database[0].endpoint
  ]
  ttl     = var.dns_zone_ttl
  type    = "CNAME"
  zone_id = var.dns_zone_id
}

resource "aws_route53_record" "aurora_reader_dns" {
  count           = local.create_module_dns
  allow_overwrite = true
  depends_on = [
    aws_rds_cluster.aurora_database,
  ]
  name = format("%s-reader", local.record_name)
  records = [
    aws_rds_cluster.aurora_database[0].reader_endpoint
  ]
  type    = "CNAME"
  ttl     = var.dns_zone_ttl
  zone_id = var.dns_zone_id
}
