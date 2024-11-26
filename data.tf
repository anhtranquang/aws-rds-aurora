data "aws_partition" "current" {}

data "aws_subnets" "selected" {
  filter {
    name = "vpc-id"
    values = [
      var.vpc_id
    ]
  }
  tags = {
    Name = var.subnet_tag
  }
}

data "aws_iam_policy_document" "monitoring_rds_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}
