resource "aws_instance" "masters" {
  count                       = "${var.master_count}"
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "${var.type}"
  vpc_security_group_ids      = ["${aws_security_group.kube_rules.id}"]
  subnet_id                   = "${aws_subnet.kubernetes_subnet.id}"
  key_name                    = "${aws_key_pair.cluster_key.key_name}"
  source_dest_check           = true
  associate_public_ip_address = true

  tags {
    Name = "${var.cluster}-master-${count.index}"
  }
}

resource "aws_instance" "workers" {
  count                       = "${var.worker_count}"
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "${var.type}"
  vpc_security_group_ids      = ["${aws_security_group.kube_rules.id}"]
  subnet_id                   = "${aws_subnet.kubernetes_subnet.id}"
  key_name                    = "${aws_key_pair.cluster_key.key_name}"
  source_dest_check           = true
  associate_public_ip_address = true

  tags {
    Name = "${var.cluster}-worker-${count.index}"
  }
}

locals {
  worker_hostnames     = "${split(",", replace(join(",", aws_instance.workers.*.private_dns), ".${var.region}.compute.internal", ""))}"
  controller_hostnames = "${split(",", replace(join(",", aws_instance.masters.*.private_dns), ".${var.region}.compute.internal", ""))}"

  master_ips = ["${aws_instance.masters.*.private_ip}"]

  worker_ips = ["${aws_instance.workers.*.private_ip}"]
}
