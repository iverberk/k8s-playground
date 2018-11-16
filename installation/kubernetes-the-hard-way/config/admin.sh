#!/bin/sh

kubectl config set-cluster kubernetes \
    --certificate-authority=../cert/ca.pem \
    --embed-certs=true \
    --server=https://192.168.10.1 \
    --kubeconfig=admin.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=../cert/admin.pem \
  --client-key=../cert/admin-key.pem \
  --embed-certs=true \
  --kubeconfig=admin.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=admin \
  --kubeconfig=admin.kubeconfig

kubectl config use-context default --kubeconfig=admin.kubeconfig
