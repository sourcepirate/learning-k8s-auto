resource "null_resource" "kubelet_config" {
  triggers {
    worker_ids = "${null_resource.tls_worker.id}"
  }

  count = "${var.worker_count}"

  provisioner "local-exec" {
    command = <<EOF
echo \"setting up the public ${count.index} facing cluster....\"
kubectl config set-cluster ${var.cluster} \
--certificate-authority=tls/ca.pem \
--embed-certs=true \
--server=https://${aws_lb.kubernetes_loadbalancer.dns_name}:6443 \
--kubeconfig=cfg/worker-${count.index}.kubeconfig

echo \"setting up the worker ${count.index} nodes credentials and context\"
kubectl config set-credentials system:node:${local.worker_hostnames[count.index]} \
--client-certificate=tls/worker-${count.index}.pem \
--client-key=tls/worker-${count.index}-key.pem \
--embed-certs=true \
--kubeconfig=cfg/worker-${count.index}.kubeconfig

kubectl config set-context default \
--cluster=${var.cluster} \
--user=system:node:${local.worker_hostnames[count.index]} \
--kubeconfig=cfg/worker-${count.index}.kubeconfig

kubectl config use-context default \
--kubeconfig=cfg/worker-${count.index}.kubeconfig
EOF
  }
}

resource "null_resource" "kube_proxy_config" {
  triggers {}

  provisioner "local-exec" {
    command = <<EOF
echo \"setting up kube proxy config \"
kubectl config set-cluster ${var.cluster} \
--certificate-authority=tls/ca.pem \
--embed-certs=true \
--server=https://${aws_lb.kubernetes_loadbalancer.dns_name}:6443 \
--kubeconfig=cfg/kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy \
--client-certificate=tls/kube-proxy.pem \
--client-key=tls/kube-proxy-key.pem \
--embed-certs=true \
--kubeconfig=cfg/kube-proxy.kubeconfig

kubectl config set-context default \
--cluster=${var.cluster} \
--user=kube-proxy \
--kubeconfig=cfg/kube-proxy.kubeconfig

kubectl config use-context default \
--kubeconfig=cfg/kube-proxy.kubeconfig
EOF
  }
}
