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


# Application Load Balancer
resource "aws_alb_target_group" "rancher-ha-tg" {
  name     = "rancher-ha-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    path = "/ping"
    port = 8080
    protocol = "HTTP"
    interval = 30
  }
}

resource "aws_alb" "rancher_ha" {
  name            = "rancher"
  subnets = [
    "${aws_subnet.rancher_ha_a.id}",
    "${aws_subnet.rancher_ha_b.id}",
    "${aws_subnet.rancher_ha_c.id}"
  ]
  security_groups = ["${aws_security_group.rancher_ha_web_alb.id}"]
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.rancher_ha.id}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${aws_iam_server_certificate.rancher_ha.arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.rancher-ha-tg.id}"
    type             = "forward"
  }
}



resource "aws_key_pair" "rancher" {
    key_name = "${var.key_name}"
    public_key = "${file("${var.key_path}.pub")}"
}


# rancher resource
resource "aws_launch_configuration" "rancher_ha" {
  name_prefix = "Launch-Config-rancher-server-ha"
  image_id    = "${lookup(var.ami, var.region)}"

  security_groups = ["${aws_security_group.rancher_ha_allow_alb.id}",
    "${aws_security_group.rancher_ha_web_alb.id}",
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
  force_delete              = false
  launch_configuration      = "${aws_launch_configuration.rancher_ha.name}"
  target_group_arns = ["${aws_alb_target_group.rancher-ha-tg.arn}"]

  vpc_zone_identifier       = [
    "${aws_subnet.rancher_ha_a.id}",
    "${aws_subnet.rancher_ha_b.id}",
    "${aws_subnet.rancher_ha_c.id}"
  ]

  tag {
    key                 = "Name"
    value               = "${var.tag_name}"
    propagate_at_launch = true
  }

  depends_on = ["aws_rds_cluster_instance.rancher_ha"]
}

output "alb_dns" {
  value = "${aws_alb.rancher_ha.dns_name}"
}

resource "aws_route53_record" "rancher" {
  zone_id = "${var.r53_zone_id}"
  name    = "${var.fqdn}"
  type    = "A"

  alias {
    name                   = "${aws_alb.rancher_ha.dns_name}"
    zone_id                = "${aws_alb.rancher_ha.zone_id}"
    evaluate_target_health = true
  }
}
