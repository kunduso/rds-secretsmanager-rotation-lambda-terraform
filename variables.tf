#Define AWS Region
variable "region" {
  description = "Infrastructure region"
  type        = string
  default     = "us-east-2"
}
#Define IAM User Access Key
variable "access_key" {
  description = "The access_key that belongs to the IAM user"
  type        = string
  sensitive   = true
  default     = ""
}
#Define IAM User Secret Key
variable "secret_key" {
  description = "The secret_key that belongs to the IAM user"
  type        = string
  sensitive   = true
  default     = ""
}
variable "name" {
  description = "The name of the application."
  type        = string
  default     = "app-12"
}
variable "vpc_cidr" {
  description = "The CIDR of the VPC."
  type        = string
  default     = "15.25.15.0/27"
}
variable "subnet_cidr" {
  description = "The CIDR blocks for the subnets."
  type        = list(any)
  default     = ["12.25.15.0/28", "12.25.15.16/28"]
}
