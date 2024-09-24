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

#no need  multi igw ,so no count
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id #link with vpc

  tags = merge(var.tags, {Name="${var.env}-igw"})
}

resource "aws_eip" "ngw" {
  count = length(lookup(lookup(var.subnets,"public",null),"cidr_block",0))
  vpc   = true
  tags  = merge(var.tags, {Name="${var.env}-ngw"}) #to get name
}

#need to get list of subnets ,so 1st do outputs.tf
#resource "aws_nat_gateway" "ngw" {
#  count = length(var.subnets["public"]"cidr_block") #multiple ngw are taking
#  allocation_id = aws_eip.ngw[count.index].id   #elip linking
#  subnet_id     = module.subnets["public"].subnet_ids[count.index] #need to get list of subnets
#  tags          = merge(var.tags, {Name="${var.env}-ngw"}) #to get name
#  }