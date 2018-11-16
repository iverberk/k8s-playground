update-ca-trust enable
cp /vagrant/cert/ca.pem /etc/pki/ca-trust/source/anchors/kubernetes-ca.pem
update-ca-trust extract
