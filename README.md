# Terraform AWS ASG for RancherOS

Based on work done by Chris Urwin and Ahmad Emneina located on [GitHub](https://github.com/chrisurwin/terraform-aws-rancher-ha).

This script will setup HA on AWS with SSL terminating on an ELB with an appropriately configured variable file.  It will also configure Route 53 to give the ELB a nicely resolvable URL.  You **must** have access to a domain in Route 53 for this to work; the `r53_zone_id` variable points to the given domain.

This was developed so that it should be simple for someone to stand up a Rancher HA server and test its functionality.

It will create the appropriate security groups, ELB, RDS and EC2 instances.

# Usage

You will need to get the encryption key and the encrypted database password prior to using this script.

To get the encryption key and encrypted database password, run the `enc-password.sh` script located in the `files` directory.

Generate an SSH key to use to connect to the RancherOS instances: `ssh-keygen -t rsa -b 4096 -f ssh/rancher -N ''` - you can call it whatever you want, as long as the `key_path` points to the right file.

Then, populate a `terraform.tfvars` file with the following _mandatory_ properties.  (Optional defaults can be found in `variables.tf` and changed if desired.)  The easiest way to do this is to copy the `terraform.tfvars.template` file and simply populate the fields.

```haml
# aws access and secret keys
access_key = ""
secret_key = ""

# ssh key
key_name = "rancher"
key_path = "./ssh/rancher"

r53_zone_id = ""

# database password rancher uses to connect to RDS
database_password = ""
database_encrypted_password = ""

# rancher stuff
fqdn = ""
ha_encryption_key = ""
```
