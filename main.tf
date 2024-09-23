resource "aws_vpc" "main" {
  cidr_block = var.cidr_block  # var1 keep in envdev-main.tfvars
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = merge(var.tags, {Name="${var.env}-vpc"})
}

module "subnets" {
  source = "./subnets"

  for_each = var.subnets
  vpc_id = aws_vpc.main.id  #this is from aws_vpc
  cidr_block = each.value["cidr_block"]
  name =each.value["name"]
  tags = var.tags
  env = var.env
  azs =each.value["azs"]

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {Name="${var.env}-vpc"})
}