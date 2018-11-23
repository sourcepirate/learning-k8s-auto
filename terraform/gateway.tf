resource "aws_internet_gateway" "kubernetes_gateway" {
  vpc_id = "${aws_vpc.kubernetes.id}"

  tags {
    Name = "${var.cluster}"
  }
}
