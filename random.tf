#https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "password" {
  length           = 128
  special          = true
  override_special = "~!#$%^&*()-_=+[]{}\\|;:<>.?"
}