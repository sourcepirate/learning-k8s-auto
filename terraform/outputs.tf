output master_ips_public {
  value = "${aws_instance.masters.*.public_ip}"
}

output master_ips_private {
  value = "${aws_instance.masters.*.private_ip}"
}

output worker_ips_public {
  value = "${aws_instance.workers.*.public_ip}"
}

output worker_ips_private {
  value = "${aws_instance.workers.*.private_ip}"
}

output etcd_ips_public {
  value = "${aws_instance.etcds.*.public_ip}"
}

output etcd_ips_private {
  value = "${aws_instance.etcds.*.private_ip}"
}

output elb_dns_name {
  value = "${aws_lb.kubernetes_loadbalancer.dns_name}"
}
