#!/bin/sh

kubectl config set-cluster kubernetes \
    --certificate-authority=../cert/ca.pem \
    --embed-certs=true \
    --server=https://192.168.10.1 \
    --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
  --client-certificate=../cert/kube-proxy.pem \
  --client-key=../cert/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=system:kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
