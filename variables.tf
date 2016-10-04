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
  default   = "us-east-1"
  description = "The region of AWS, for AMI lookups."
}

variable "ami" {
  description = "AWS RancherOS AMI ID"
  default {
    us-east-1 = "ami-a8d2a4bf"
    us-west-1 = "ami-fccb879c"
    us-west-2 = "ami-1ed3007e"
  }
}

variable "tag_name" {
  default   = "rancher-ha"
  description = "Name tag for the servers"
}

variable "key_name" {
  default = "rancher-example"
  description = "SSH key name in your AWS account for AWS instances."
}

variable "key_path" {
  default = "~/.ssh/rancher-example"
  description = "Local path of the SSH private key"
}

variable "ha_size" {
  default = "3"
  description = "The number of nodes in the HA cluster; three (3) or five (5)."
}

variable "ami_id" {}

variable "instance_type" {}

variable "database_port" {}

variable "database_name" {}

variable "database_username" {}

variable "database_password" {}

variable "database_encrypted_password" {}

variable "ha_encryption_key" {}

variable "ha_registration_url" {}

variable "vpc_id" {}

variable "az1" {}

variable "az2" {}

variable "az3" {}

variable "zone_id" {}

variable "fqdn" {}

variable "database_instance_class" {}

variable "rancher_version" {}

variable "r53_zone_id" {}

variable "rancher_endpoint_name" {}
