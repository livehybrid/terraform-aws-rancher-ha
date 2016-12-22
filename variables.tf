#------------------------------------------#
# AWS Environment Values
#------------------------------------------#
variable "access_key" {
  description = "AWS account access key ID"
}

variable "secret_key" {
  description = "AWS account secret access key"
}

variable "region" {
  default     = "us-east-1"
  description = "The region of AWS, for AMI lookups."
}

variable "ami" {
  description = "AWS RancherOS AMI ID"

  default {
    us-east-1 = "ami-812ec0ec"
    us-west-1 = "ami-ea7a058a"
    us-west-2 = "ami-4f50a72f"
    eu-west-1 = "ami-c62170b5"
    eu-west-2 = "ami-65e8e201"
  }
}

variable "vpc_id" {
  default = "xxx"
  description = "The ID of your VPC"
}

variable "tag_name" {
  default     = "rancher-ha"
  description = "Name tag for the servers"
}

variable "key_name" {
  default     = "rancher-example"
  description = "SSH key name in your AWS account for AWS instances."
}

variable "key_path" {
  default     = "~/.ssh/rancher-example"
  description = "Local path of the SSH private key"
}

variable "ha_size" {
  default     = "3"
  description = "The number of nodes in the HA cluster; three (3) or five (5)."
}

variable "instance_type" {
  default     = "t2.large"          # RAM Requirements >= 4gb
  description = "AWS Instance type"
}

variable "r53_zone_id" {
  description = "The Route53 zone ID"
}

#------------------------------------------#
# RDS Environment Values
#------------------------------------------#
variable "database_instance_class" {
  description = "RDS instance class"
  default     = "db.r3.large"
}

variable "database_name" {
  description = "Name of the database"
  default     = "rancher"
}

variable "database_port" {
  description = "Port for the database"
  default     = "3306"
}

variable "database_username" {
  description = "Username for the database"
  default     = "rancher"
}

variable "database_password" {
  description = "Password for the database"
}

variable "database_encrypted_password" {
  description = "Encrypted password for the database"
}

#------------------------------------------#

# Rancher Environment Values

#------------------------------------------#

variable "ha_encryption_key" {}

variable "fqdn" {
  description = "URL that the Rancher cluster will be accessible via"
}

variable "rancher_version" {
  description = "The Rancher version to use/install"
  default     = "rancher/server:v1.2.0"
}

variable "email" {
  description = "Your email address to create SSL Cert against"
  default     = "bob@google.com"
}
