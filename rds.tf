#Create RDS database
resource "aws_db_instance" "rancherdb" {
  allocated_storage      = 10
  engine                 = "mysql"
  instance_class         = "${var.database_instance_class}"                 #This is smaller than the recommended size and should be increased according to environment
  name                   = "${var.database_name}"
  username               = "${var.database_username}"
  password               = "${var.database_password}"
  vpc_security_group_ids = ["${aws_security_group.rancher_ha_allow_db.id}"]
}
