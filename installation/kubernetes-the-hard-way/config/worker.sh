#!/bin/sh

for instance in worker-1 worker-2 worker-3; do
  kubectl config set-cluster kubernetes \
    --certificate-authority=../cert/ca.pem \
    --embed-certs=true \
    --server=https://192.168.10.1 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=../cert/${instance}.pem \
    --client-key=../cert/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done
