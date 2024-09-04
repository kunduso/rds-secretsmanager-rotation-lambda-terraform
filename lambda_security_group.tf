#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "lambda" {
  name        = "${var.name}-lambda-sg"
  description = "Security group for Lambda in ${var.name}"
  vpc_id      = aws_vpc.this.id
  tags = {
    "Name" = "${var.name}-lambda-sg"
  }
  # checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
  # This security group is attached to the Amazon ElastiCache Serverless resource
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "egress_lambda_sg" {
  description       = "allow traffic from Lambda"
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.lambda.id
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "ingress_lambda_sg" {
  description       = "allow traffic from vpc to the lambda"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.lambda.id
}