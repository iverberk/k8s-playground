#!/bin/sh

echo "Configuring worker..."

yum install -y socat conntrack ipset iptables

mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /opt/containerd \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

echo "Installing worker binaries..."

cd /vagrant/bin

cp runsc-50c283b9f56bb7200938d9e207355f05f79f0d17 runsc
cp runc.amd64 runc
chmod +x kubectl kube-proxy kubelet runc runsc
cp kubectl kube-proxy kubelet runc runsc /usr/local/bin/
tar -xvf crictl-v1.12.0-linux-amd64.tar.gz -C /usr/local/bin/
tar -xvf cni-plugins-amd64-v0.6.0.tgz -C /opt/cni/bin/
tar -xvf containerd-1.2.0-rc.0.linux-amd64.tar.gz -C /opt/containerd/

echo "Configuring CNI Networking..."

cat <<EOF | tee /etc/cni/net.d/10-bridge.conf
{
    "cniVersion": "0.3.1",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "$1"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF

cat <<EOF | tee /etc/cni/net.d/99-loopback.conf
{
    "cniVersion": "0.3.1",
    "type": "loopback"
}
EOF

echo "Configuring Containerd..."

mkdir -p /etc/containerd/

cat << EOF | tee /etc/containerd/config.toml
[plugins]
  [plugins.cri.containerd]
    snapshotter = "overlayfs"
    [plugins.cri.containerd.default_runtime]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/local/bin/runc"
      runtime_root = ""
    [plugins.cri.containerd.untrusted_workload_runtime]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/local/bin/runsc"
      runtime_root = "/run/containerd/runsc"
    [plugins.cri.containerd.gvisor]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/local/bin/runsc"
      runtime_root = "/run/containerd/runsc"
EOF

cp /vagrant/scripts/systemd/containerd.service /etc/systemd/system/containerd.service

echo "Configuring Kubelet..."

cp /vagrant/cert/${HOSTNAME}-key.pem /vagrant/cert/${HOSTNAME}.pem /var/lib/kubelet/
cp /vagrant/config/${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
cp /vagrant/cert/ca.pem /var/lib/kubernetes/

cat <<EOF | tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "$1"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${HOSTNAME}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${HOSTNAME}-key.pem"
EOF

cp /vagrant/scripts/systemd/kubelet.service /etc/systemd/system/kubelet.service

echo "Configuring kube-proxy..."

cp /vagrant/config/kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig

cat <<EOF | tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"
EOF

cp /vagrant/scripts/systemd/proxy.service /etc/systemd/system/kube-proxy.service

echo "Starting worker services..."

systemctl daemon-reload
systemctl enable containerd kubelet kube-proxy systemd-resolved
systemctl start containerd kubelet kube-proxy systemd-resolved
