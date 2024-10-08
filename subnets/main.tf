resource "aws_subnet" "main" {

  count = length(var.cidr_block)  # public & private
  vpc_id     = var.vpc_id #this is from aws_vpc
  cidr_block = var.cidr_block[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(var.tags, {Name="${var.env}-${var.name}-${count.index+1}"})
}

resource "aws_route_table" "main" {
  count = length(var.cidr_block)
  vpc_id = var.vpc_id #this is from aws_vpc

  tags  = merge(var.tags, {Name="${var.env}-${var.name}-rt-${count.index+1}"}) #to get name
}

#link : Attach public & private-router to the subnet [ public subnets – adding internet gateway || private subnet – adding nat-gate ]
resource "aws_route_table_association" "associate" {
  count =  length(var.cidr_block)
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.main[count.index].id
}




