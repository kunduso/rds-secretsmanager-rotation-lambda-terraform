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
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "endpoint_sg" {
  name        = "endpoint_access"
  description = "allow inbound traffic"
  vpc_id      = aws_vpc.this.id
  tags = {
    "Name" = "${var.name}-endpoint-sg"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "ingress_vpc_endpoint" {
  description       = "Enable access for the endpoints."
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.this.cidr_block]
  security_group_id = aws_security_group.endpoint_sg.id
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  tags = {
    "Name" = "${var.name}-secrets-manager"
  }
}