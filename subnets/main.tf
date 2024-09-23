resource "aws_subnet" "main" {

  count = length(var.cidr_block)  # public & private
  vpc_id     = var.vpc_id
  cidr_block = var.cidr_block[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(var.tags, {Name="${var.env}-${var.name}-${count.index+1}"})
}