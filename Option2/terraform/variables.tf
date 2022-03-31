variable "AWS_ACCESS_KEY" {
  description = "AWS Access Key Id"
  type        = string
  sensitive   = true
}

variable "AWS_SECRET_KEY" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}

variable "AWS_REGION" {
  default = "us-east-1"
}
variable "VPC_CIDR" {
  default = "10.10.0.0/22"
}

variable "PUB1_CIDR" {
  default = "10.10.0.0/24"
}

variable "PUB2_CIDR" {
  default = "10.10.1.0/24"
}
variable "PVT1_CIDR" {
  default = "10.10.2.0/24"
}
variable "PVT2_CIDR" {
  default = "10.10.3.0/24"
}