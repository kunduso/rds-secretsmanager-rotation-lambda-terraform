
# Read the JSON file
#https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file
data "local_file" "user_list" {
  filename = "${path.module}/user_list.json"
}

# Create SSM Parameter
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter
resource "aws_ssm_parameter" "user_list" {
  name        = "/${var.name}/db_user_list" # Replace with your desired parameter name
  description = "User and database mappings for Amazon RDS for PostgreSQL DB users."
  type        = "String"
  value       = data.local_file.user_list.content
}