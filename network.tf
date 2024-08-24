
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "this" {
  #checkov:skip=CKV2_AWS_11: This is non prod and hence disabled.
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name" = "${var.name}"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "db" {
  count             = length(var.subnet_cidr_db)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_cidr_db[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    "Name" = "${var.name}subnet-${count.index + 1}"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "this_rt" {
  vpc_id = aws_vpc.this.id
  tags = {
    "Name" = "${var.name}-route-table"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "db" {
  count          = length(var.subnet_cidr_db)
  subnet_id      = element(aws_subnet.db.*.id, count.index)
  route_table_id = aws_route_table.this_rt.id
}