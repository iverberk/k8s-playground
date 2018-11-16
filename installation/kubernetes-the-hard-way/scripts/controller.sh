echo "Installing controller binaries..."

cd /vagrant/bin
chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
cp kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/

echo "Configuring the controller services..."

mkdir -p /etc/kubernetes/config /var/lib/kubernetes

cd /vagrant/cert
cp ca.pem ca-key.pem api-server-key.pem api-server.pem service-account-key.pem service-account.pem /var/lib/kubernetes/

cd /vagrant/config
cp encryption-config.yaml /var/lib/kubernetes/

cat <<EOF | tee /etc/kubernetes/config/kube-scheduler.yaml
apiVersion: componentconfig/v1alpha1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF

cp /vagrant/scripts/systemd/api-server.service /etc/systemd/system/api-server.service
IP=$(hostname -I | cut -d' ' -f2)
sed -i s/%IP%/$IP/g /etc/systemd/system/api-server.service

cp /vagrant/config/kube-scheduler.kubeconfig /var/lib/kubernetes/
cp /vagrant/scripts/systemd/scheduler.service /etc/systemd/system/scheduler.service

cp /vagrant/config/kube-controller-manager.kubeconfig /var/lib/kubernetes/
cp /vagrant/scripts/systemd/controller-manager.service /etc/systemd/system/controller-manager.service

echo "Starting the controller services..."

systemctl daemon-reload
systemctl enable api-server controller-manager scheduler
systemctl start api-server controller-manager scheduler
