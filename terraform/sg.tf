resource "aws_security_group" "kube_rules" {
  name        = "${var.cluster}-sg-rules"
  description = "kubernetes security group rules"
  vpc_id      = "${aws_vpc.kubernetes.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr}"]
  }

  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.cluster}"
  }
}
