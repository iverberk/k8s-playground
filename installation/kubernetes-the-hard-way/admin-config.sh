#!/bin/sh

kubectl config set-cluster kubernetes \
  --certificate-authority=cert/ca.pem \
  --embed-certs=true \
  --server=https://192.168.10.1

kubectl config set-credentials admin \
  --client-certificate=cert/admin.pem \
  --client-key=cert/admin-key.pem

kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=admin

kubectl config use-context kubernetes
