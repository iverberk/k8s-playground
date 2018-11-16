#!/bin/sh

KUBE_VERSION=v1.12.2
ETCD_VERSION=v3.3.10

./clean.sh

cd bin

wget -q --https-only \
  "https://storage.googleapis.com/kubernetes-release/release/$KUBE_VERSION/bin/linux/amd64/kube-apiserver" \
  "https://storage.googleapis.com/kubernetes-release/release/$KUBE_VERSION/bin/linux/amd64/kube-controller-manager" \
  "https://storage.googleapis.com/kubernetes-release/release/$KUBE_VERSION/bin/linux/amd64/kube-scheduler" \
  "https://storage.googleapis.com/kubernetes-release/release/$KUBE_VERSION/bin/linux/amd64/kubectl"

wget -q --https-only https://github.com/coreos/etcd/releases/download/$ETCD_VERSION/etcd-$ETCD_VERSION-linux-amd64.tar.gz
tar -xvf etcd-$ETCD_VERSION-linux-amd64.tar.gz
mv etcd-$ETCD_VERSION-linux-amd64/etcd* .
rm -rf etcd-$ETCD_VERSION-linux-amd64 etcd-v3.3.10-linux-amd64.tar.gz

wget -q --https-only \
  https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.12.0/crictl-v1.12.0-linux-amd64.tar.gz \
  https://storage.googleapis.com/kubernetes-the-hard-way/runsc-50c283b9f56bb7200938d9e207355f05f79f0d17 \
  https://github.com/opencontainers/runc/releases/download/v1.0.0-rc5/runc.amd64 \
  https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-plugins-amd64-v0.6.0.tgz \
  https://github.com/containerd/containerd/releases/download/v1.2.0-rc.0/containerd-1.2.0-rc.0.linux-amd64.tar.gz \
  https://storage.googleapis.com/kubernetes-release/release/$KUBE_VERSION/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/$KUBE_VERSION/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/$KUBE_VERSION/bin/linux/amd64/kubelet

cd ../cert
./cert.sh

cd ../config
./config.sh

cd ../

./k8s-api.sh

vagrant up

./admin-config.sh
