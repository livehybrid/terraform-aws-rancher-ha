#------------------------------------------#
# RDS Database Configuration
#------------------------------------------#
resource "aws_db_subnet_group" "rancher_ha" {
  name        = "${var.tag_name}-db-subnet-group"
  description = "Rancher HA Subnet Group"

  subnet_ids = [
    "${aws_subnet.rancher_ha_a.id}",
    "${aws_subnet.rancher_ha_b.id}",
    "${aws_subnet.rancher_ha_c.id}",
  ]

  tags {
    Name = "${var.tag_name}-db-subnet-group"
  }
}

resource "aws_rds_cluster_instance" "rancher_ha" {
  count                = 2
  identifier           = "${var.tag_name}-db-${count.index}"
  cluster_identifier   = "${aws_rds_cluster.rancher_ha.id}"
  instance_class       = "${var.database_instance_class}"
  publicly_accessible  = false
  db_subnet_group_name = "${aws_db_subnet_group.rancher_ha.name}"
}

resource "aws_rds_cluster" "rancher_ha" {
  cluster_identifier     = "${var.tag_name}-db"
  database_name          = "${var.database_name}"
  master_username        = "${var.database_username}"
  master_password        = "${var.database_password}"
  db_subnet_group_name   = "${aws_db_subnet_group.rancher_ha.name}"
  availability_zones     = ["${var.region}a", "${var.region}b", "${var.region}c"]
  vpc_security_group_ids = ["${aws_security_group.rancher_ha_allow_db.id}"]
}
