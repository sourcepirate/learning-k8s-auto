resource "aws_vpc_dhcp_options" "kube_dhcp_opt" {
  domain_name         = "${var.region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name = "${var.cluster}"
  }
}
