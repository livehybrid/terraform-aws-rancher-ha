# User-data template
data "template_file" "user_data" {
  template = "${file("${path.module}/files/userdata.template")}"

  vars {
    # Database
    database_address            = "${aws_rds_cluster.rancher_ha.endpoint}"
    database_port               = "${var.database_port}"
    database_name               = "${var.database_name}"
    database_username           = "${var.database_username}"
    database_password           = "${var.database_password}"
    database_encrypted_password = "${var.database_encrypted_password}"
    ha_registration_url         = "https://${var.fqdn}"
    scale_desired_size          = "${var.ha_size}"
    rancher_version             = "${var.rancher_version}"

    #Rancher HA encryption key
    encryption_key = "${var.ha_encryption_key}"
  }
}

provider "aws" {
  region = "${var.region}"
}

# Elastic Load Balancer
resource "aws_elb" "rancher_ha" {
  name                      = "rancher-ha"
  cross_zone_load_balancing = true
  internal                  = false
  security_groups           = ["${aws_security_group.rancher_ha_web_elb.id}"]

  subnets = [
    "${aws_subnet.rancher_ha_a.id}",
    "${aws_subnet.rancher_ha_b.id}",
    "${aws_subnet.rancher_ha_d.id}",
  ]

  listener {
    instance_port      = 81
    instance_protocol  = "tcp"
    lb_port            = 443
    lb_protocol        = "ssl"
    ssl_certificate_id = "${aws_iam_server_certificate.rancher_ha.arn}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 4
    timeout             = 5

    #target = "TCP:22"
    target   = "HTTP:80/ping"
    interval = 7
  }
}

resource "aws_key_pair" "rancher" {
    key_name = "${var.key_name}"
    public_key = "${file("${var.key_path}.pub")}"
}

resource "aws_proxy_protocol_policy" "rancher_ha" {
  load_balancer  = "${aws_elb.rancher_ha.name}"
  instance_ports = ["81", "444"]
}

# rancher resource
resource "aws_launch_configuration" "rancher_ha" {
  name_prefix = "Launch-Config-rancher-server-ha"
  image_id    = "${lookup(var.ami, var.region)}"

  security_groups = ["${aws_security_group.rancher_ha_allow_elb.id}",
    "${aws_security_group.rancher_ha_web_elb.id}",
    "${aws_security_group.rancher_ha_allow_internal.id}",
  ]

  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.rancher.key_name}"
  user_data                   = "${data.template_file.user_data.rendered}"
  associate_public_ip_address = false
  ebs_optimized               = false
}

resource "aws_autoscaling_group" "rancher_ha" {
  name                      = "${var.tag_name}-asg"
  min_size                  = "${var.ha_size}"
  max_size                  = "${var.ha_size}"
  desired_capacity          = "${var.ha_size}"
  health_check_grace_period = 900
  health_check_type         = "ELB"
  force_delete              = false
  launch_configuration      = "${aws_launch_configuration.rancher_ha.name}"
  load_balancers            = ["${aws_elb.rancher_ha.name}"]
  availability_zones        = ["${var.region}a", "${var.region}b", "${var.region}d"]

  tag {
    key                 = "Name"
    value               = "${var.tag_name}"
    propagate_at_launch = true
  }
}

output "elb_dns" {
  value = "${aws_elb.rancher_ha.dns_name}"
}

resource "aws_route53_record" "rancher" {
  zone_id = "${var.r53_zone_id}"
  name    = "${var.fqdn}"
  type    = "A"

  alias {
    name                   = "${aws_elb.rancher_ha.dns_name}"
    zone_id                = "${aws_elb.rancher_ha.zone_id}"
    evaluate_target_health = true
  }
}
