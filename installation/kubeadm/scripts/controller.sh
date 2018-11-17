cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum install -y kubelet-1.11.4-0 kubeadm kubectl-1.11.4-0 --disableexcludes=kubernetes docker-ce-0:18.06.1.ce-3.el7.x86_64 ipvsadm

systemctl enable kubelet docker && systemctl start kubelet docker

modprobe br_netfilter
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe nf_conntrack_ipv4
echo "br_netfilter" > /etc/modules-load.d/br_netfilter.conf

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

if [ -d /home/vagrant/certs/pki ]; then
  mkdir -p /etc/kubernetes
  mv /home/vagrant/certs/pki /etc/kubernetes
  mv /home/vagrant/admin.conf /etc/kubernetes

  kubeadm alpha phase certs all --config /home/vagrant/controller-$1.yaml
  kubeadm alpha phase kubelet config write-to-disk --config /home/vagrant/controller-$1.yaml
  kubeadm alpha phase kubelet write-env-file --config /home/vagrant/controller-$1.yaml
  kubeadm alpha phase kubeconfig kubelet --config /home/vagrant/controller-$1.yaml
  systemctl start kubelet

  export KUBECONFIG=/etc/kubernetes/admin.conf
  kubectl exec -n kube-system etcd-controller-1 -- etcdctl  \
    --ca-file /etc/kubernetes/pki/etcd/ca.crt               \
    --cert-file /etc/kubernetes/pki/etcd/peer.crt           \
    --key-file /etc/kubernetes/pki/etcd/peer.key            \
    --endpoints=https://192.168.10.2:2379 member add controller-$1 https://$2:2380
  kubeadm alpha phase etcd local --config /home/vagrant/controller-$1.yaml

  kubeadm alpha phase kubeconfig all --config /home/vagrant/controller-$1.yaml
  kubeadm alpha phase controlplane all --config /home/vagrant/controller-$1.yaml
  kubeadm alpha phase kubelet config annotate-cri --config /home/vagrant/controller-$1.yaml
  kubeadm alpha phase mark-master --config /home/vagrant/controller-$1.yaml
else
  kubeadm init --config /home/vagrant/controller-$1.yaml
fi
