resource "null_resource" "tls_ca" {
  provisioner "local-exec" {
    command = "cfssl gencert -initca tls/ca-csr.json | cfssljson -bare tls/ca"
  }
}

resource "null_resource" "tls_admin" {
  triggers = {
    tls_ca = "${null_resource.tls_ca.id}"
  }

  provisioner "local-exec" {
    command = <<EOF
cfssl gencert \
  -ca=tls/ca.pem -ca-key=tls/ca-key.pem \
  -config=tls/ca-config.json \
  -profile=kubernetes \
  tls/admin-csr.json \
  | cfssljson -bare tls/admin
EOF
  }
}

data "template_file" "worker_csr" {
  # Terraform does not allow to use `length` function on computed list
  # count    = "${length(aws_instance.worker.*.id)}"
  count = "${var.worker_count}"

  template = "${file("../tls/worker-csr.tpl.json")}"

  vars = {
    # instance_hostname = "${element(split(".", aws_instance.worker.*.private_dns[count.index]), 0)}"
    instance_hostname = "${local.worker_hostnames[count.index]}"
  }
}

resource "local_file" "worker_csr" {
  # Terraform does not allow to use `length` function on computed list
  # count    = "${length(aws_instance.worker.*.id)}"
  count = "${var.worker_count}"

  content  = "${data.template_file.worker_csr.*.rendered[count.index]}"
  filename = "tls/worker-${count.index}-csr.json"
}

resource "null_resource" "tls_worker" {
  triggers = {
    tls_ca = "${null_resource.tls_ca.id}"
  }

  # Terraform does not allow to use `length` function on computed list
  # count = "${length(aws_instance.worker.*.id)}"
  count = "${var.worker_count}"

  provisioner "local-exec" {
    command = <<EOF
cfssl gencert \
  -ca=tls/ca.pem -ca-key=tls/ca-key.pem \
  -config=tls/ca-config.json \
  -hostname=${local.worker_hostnames[count.index]},${aws_instance.workers.*.public_ip[count.index]},${aws_instance.workers.*.private_ip[count.index]} \
  -profile=kubernetes \
  ${local_file.worker_csr.*.filename[count.index]} \
  | cfssljson -bare tls/worker-${count.index}
EOF
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${tls_private_key.k8s.private_key_pem}"
  }

  provisioner "file" {
    source      = "tls/ca.pem"
    destination = "/home/ubuntu/ca.pem"
  }

  provisioner "file" {
    source      = "tls/worker-${count.index}-key.pem"
    destination = "worker-${count.index}-key.pem"
  }

  provisioner "file" {
    source      = "tls/worker-${count.index}.pem"
    destination = "worker-${count.index}.pem"
  }
}

resource "null_resource" "tls_kube_proxy" {
  triggers = {
    tls_ca = "${null_resource.tls_ca.id}"
  }

  provisioner "local-exec" {
    command = <<EOF
cfssl gencert \
  -ca=tls/ca.pem -ca-key=tls/ca-key.pem \
  -config=tls/ca-config.json \
  -profile=kubernetes \
  tls/kube-proxy-csr.json \
  | cfssljson -bare tls/kube-proxy
EOF
  }
}

resource "null_resource" "tls_kubernetes" {
  triggers = {
    tls_ca = "${null_resource.tls_ca.id}"
  }

  provisioner "local-exec" {
    command = <<EOF
cfssl gencert \
  -ca=tls/ca.pem -ca-key=tls/ca-key.pem \
  -config=tls/ca-config.json \
  -hostname=10.32.0.1,${join(",", aws_instance.masters.*.private_ip)},${join(",", local.controller_hostnames)},${aws_lb.kubernetes_loadbalancer.dns_name},127.0.0.1,kubernetes.default \
  -profile=kubernetes \
  tls/kubernetes-csr.json \
  | cfssljson -bare tls/kubernetes
EOF
  }
}

resource "null_resource" "tls_controller" {
  triggers = {
    tls_ca         = "${null_resource.tls_ca.id}"
    tls_kubernetes = "${null_resource.tls_kubernetes.id}"
  }

  # Terraform does not allow to use `length` function on computed list
  # count = "${length(aws_instance.controller.*.id)}"
  count = "${var.master_count}"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${tls_private_key.k8s.private_key_pem}"
  }

  provisioner "file" {
    source      = "tls/ca.pem"
    destination = "/home/ubuntu/ca.pem"
  }

  provisioner "file" {
    source      = "tls/ca-key.pem"
    destination = "/home/ubuntu/ca-key.pem"
  }

  provisioner "file" {
    source      = "tls/kubernetes-key.pem"
    destination = "/home/ubuntu/kubernetes-key.pem"
  }

  provisioner "file" {
    source      = "tls/kubernetes.pem"
    destination = "/home/ubuntu/kubernetes.pem"
  }
}
