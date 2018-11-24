resource "aws_lb" "kubernetes_loadbalancer" {
  name               = "${var.cluster}-loadbalancer"
  subnets            = ["${aws_subnet.kubernetes_subnet.id}"]
  internal           = false
  load_balancer_type = "network"

  tags {
    Name = "${var.cluster}"
  }
}

resource "aws_lb_target_group" "kubernetes_lb_group" {
  name        = "${var.cluster}-lbgroup"
  protocol    = "TCP"
  port        = 6443
  vpc_id      = "${aws_vpc.kubernetes.id}"
  target_type = "ip"
}

resource "aws_lb_listener" "kubernetes_listener" {
  load_balancer_arn = "${aws_lb.kubernetes_loadbalancer.arn}"
  protocol          = "TCP"
  port              = 6443

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.kubernetes_lb_group.arn}"
  }

  depends_on = ["aws_lb_target_group.kubernetes_lb_group"]
}

resource "aws_lb_target_group_attachment" "kuberenetes_group_attachment" {
  count            = "${var.master_count}"
  target_group_arn = "${aws_lb_target_group.kubernetes_lb_group.arn}"
  target_id        = "${local.master_ips[count.index]}"

  depends_on = ["aws_lb_target_group.kubernetes_lb_group"]
}
