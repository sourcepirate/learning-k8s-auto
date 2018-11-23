resource "aws_subnet" "kubernetes_subnet" {
  cidr_block = "${var.cidr}"
  vpc_id     = "${aws_vpc.kubernetes.id}"

  tags {
    Name = "${var.cluster}"
  }
}
