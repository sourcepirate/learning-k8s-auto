resource "aws_iam_policy" "instance_policy" {
  name = "instance_policy"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*"
      ],
      "Resource": [
        "*"
      ]
    }
}
EOF
}

resource "aws_iam_role" "ec2-role" {
  name = "node-role"

  assume_role_policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
EOF
}

resource "aws_iam_instance_profile" "profile" {
  name = "ec2-perms"
  path = "/"
  role = "${aws_iam_role.ec2-role.name}"
}

resource "aws_iam_role_policy_attachment" "ec2_role_attach" {
  role       = "${aws_iam_role.ec2-role.name}"
  policy_arn = "${aws_iam_policy.instance_policy.arn}"
}

resource "aws_instance" "masters" {
  count                       = "${var.master_count}"
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "${var.type}"
  vpc_security_group_ids      = ["${aws_security_group.kube_rules.id}"]
  subnet_id                   = "${aws_subnet.kubernetes_subnet.id}"
  key_name                    = "${aws_key_pair.cluster_key.key_name}"
  source_dest_check           = true
  associate_public_ip_address = true

  iam_instance_profile = "${aws_iam_instance_profile.profile.id}"

  tags {
    Name              = "${var.cluster}-master-${count.index}"
    KubernetesCluster = "${var.cluster}"
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
    Name              = "${var.cluster}-worker-${count.index}"
    KubernetesCluster = "${var.cluster}"
  }

  iam_instance_profile = "${aws_iam_instance_profile.profile.id}"
}

resource "aws_instance" "etcds" {
  count                       = "${var.etcd_count}"
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "${var.type}"
  vpc_security_group_ids      = ["${aws_security_group.kube_rules.id}"]
  subnet_id                   = "${aws_subnet.kubernetes_subnet.id}"
  key_name                    = "${aws_key_pair.cluster_key.key_name}"
  source_dest_check           = true
  associate_public_ip_address = true

  tags {
    Name              = "${var.cluster}-etcd-${count.index}"
    KubernetesCluster = "${var.cluster}"
  }
}

locals {
  worker_hostnames     = "${split(",", replace(join(",", aws_instance.workers.*.private_dns), ".${var.region}.compute.internal", ""))}"
  controller_hostnames = "${split(",", replace(join(",", aws_instance.masters.*.private_dns), ".${var.region}.compute.internal", ""))}"

  master_ips = ["${aws_instance.masters.*.private_ip}"]

  worker_ips = ["${aws_instance.workers.*.private_ip}"]

  etcds = ["${aws_instance.etcds.*.private_ip}"]
}
