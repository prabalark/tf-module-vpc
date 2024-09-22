resource "aws_vpc" "main" {
  cidr_block = var.cidr_block  # var1 keep in envdev-main.tfvars
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = merge(var.tags, {name="${var.env}"})
}
