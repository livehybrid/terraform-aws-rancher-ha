# Create the private key for the registration (not the certificate)
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

# Set up a registration using a private key from tls_private_key
resource "acme_registration" "reg" {
  server_url      = "https://acme-v01.api.letsencrypt.org/directory"
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = "${var.email}"
}

# Create a certificate
resource "acme_certificate" "certificate" {
  server_url      = "https://acme-v01.api.letsencrypt.org/directory"
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  common_name     = "${var.fqdn}"

  dns_challenge {
    provider = "route53"

    config {
      AWS_ACCESS_KEY_ID     = "${var.access_key}"
      AWS_SECRET_ACCESS_KEY = "${var.secret_key}"
      AWS_DEFAULT_REGION    = "us-east-1"
    }
  }

  registration_url = "${acme_registration.reg.id}"
}

output "acme_certificate" "pem" {
  value = "${acme_certificate.certificate.private_key_pem}"
}

resource "aws_iam_server_certificate" "rancher_ha" {
  name              = "${var.tag_name}-certificate"
  certificate_body  = "${acme_certificate.certificate.certificate_pem}"
  private_key       = "${acme_certificate.certificate.private_key_pem}"
  certificate_chain = "${acme_certificate.certificate.issuer_pem}"
}
