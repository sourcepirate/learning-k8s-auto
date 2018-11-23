#!/bin/bash

cfssl gencert -initca tls/ca-csr.json | cfssljson -bare tls/ca
cfssl gencert \
  -ca=tls/ca.pem \
  -ca-key=tls/ca-key.pem \
  -config=tls/ca-config.json \
  -profile=kubernetes \
  tls/admin-csr.json | cfssljson -bare tls/admin
