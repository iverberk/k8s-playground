cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes docker-ce-0:18.06.1.ce-3.el7.x86_64 ipvsadm

echo "KUBELET_EXTRA_ARGS=--node-ip=$1" > /etc/sysconfig/kubelet

systemctl enable kubelet docker && systemctl start kubelet docker

modprobe br_netfilter
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe nf_conntrack_ipv4
echo "br_netfilter" > /etc/modules-load.d/br_netfilter.conf
echo "ip_vs" > /etc/modules-load.d/ip_vs.conf
echo "ip_vs_rr" > /etc/modules-load.d/ip_vs_rr.conf
echo "ip_vs_wrr" > /etc/modules-load.d/ip_vs_wrr.conf
echo "ip_vs_sh" > /etc/modules-load.d/ip_vs_sh.conf
echo "nf_conntrack_ipv4" > /etc/modules-load.d/nf_conntrack_ipv4.conf

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

kubeadm join 192.168.10.1:443 --token aizj0m.9h0heu6j9gf439l9 --discovery-token-unsafe-skip-ca-verification
