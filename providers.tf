provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = var.assume_role
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "secret"

  assume_role {
    role_arn = local.secret_assume_role
  }
}
