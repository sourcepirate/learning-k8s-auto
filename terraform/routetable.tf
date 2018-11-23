resource "aws_route_table" "kubernetes_table" {
  vpc_id = "${aws_vpc.kubernetes.id}"

  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.kubernetes_gateway.id}"
  }

  tags {
    Name = "${var.cluster}"
  }
}

resource "aws_route_table_association" "kubernetes_assoc" {
  subnet_id      = "${aws_subnet.kubernetes_subnet.id}"
  route_table_id = "${aws_route_table.kubernetes_table.id}"
}
