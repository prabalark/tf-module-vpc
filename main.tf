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

# no need  multi igw ,so no count
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id #link with vpc

  tags = merge(var.tags, {Name="${var.env}-igw"})
}

resource "aws_eip" "ngw" {
  count = length(lookup(lookup(var.subnets,"public",null),"cidr_block",0))
  tags  = merge(var.tags, {Name="${var.env}-engw"}) #to get name
}

# need to get list of subnets ,so 1st do outputs.tf
resource "aws_nat_gateway" "ngw" {
  count = length(var.subnets["public"].cidr_block) #multiple ngw are taking
  allocation_id = aws_eip.ngw[count.index].id   #elip linking
  subnet_id     = module.subnets["public"].subnet_ids[count.index] #need to get list of subnets

  tags  = merge(var.tags, {Name="${var.env}-ngw"}) #to get name
}

#output "vpc" {
#  value = "module.vpc"
#}

# This step we will do in route table creation in manual step
# public bcz internet_gateway
resource "aws_route" "rtprigw" {
  count                  = length(module.subnets["public"].route_table_ids)
  route_table_id         = module.subnets["public"].route_table_ids[count.index]
  gateway_id             = aws_internet_gateway.igw.id # only one id we bcz igw
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "rtprngw" {
  count                  = length(local.all_private_subnet_ids)
  route_table_id         = local.all_private_subnet_ids[count.index]
  nat_gateway_id         = element(aws_nat_gateway.ngw.*.id,count.index)
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id = var.default_vpc_id
  vpc_id      = aws_vpc.main.id
  auto_accept = true
}

resource "aws_route" "peering_connection-route" {
  count = length(local.all_private_subnet_ids)
  route_table_id = element(local.all_private_subnet_ids, count.index)
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  destination_cidr_block    = var.default_vpc_cidr
}

resource "aws_route" "peering_connection-route-in-default-vpc" {
  route_table_id            = var.default_vpc_rtid
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  destination_cidr_block    = var.cidr_block
}




