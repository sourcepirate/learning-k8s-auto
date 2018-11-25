#!/bin/bash

pip install jinja2
cfssl gencert -initca certificates/ca-csr.json | cfssljson -bare gen_certs/ca

python scripts/build-certificates.py
cfssl gencert \
-ca=gen_certs/ca.pem \
-ca-key=gen_certs/ca-key.pem \
-config=certificates/ca-config.json \
-profile=kubernetes \
gen_certs/kubernetes-csr.json | cfssljson -bare gen_certs/kubernetes

master_count=$1
worker_count=$2
etcd_count=$3
