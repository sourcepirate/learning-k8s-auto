resource "tls_private_key" "cluster_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "aws_key_pair" "cluster_key" {
  key_name   = "kubernetes"
  public_key = "${tls_private_key.cluster_key.public_key_openssh}"
}
