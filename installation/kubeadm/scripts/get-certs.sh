# This is necessary to allow copying of the certificates
# NEVER do this on an actual production installation!
vagrant ssh controller-1 -c "sudo chown -R vagrant:root /etc/kubernetes/pki /etc/kubernetes/admin.conf" 2> /dev/null

vagrant ssh-config controller-1 > ssh-config 2> /dev/null

mkdir -p certs/pki/etcd

scp -r -F ssh-config controller-1:/etc/kubernetes/pki/ca.crt certs/pki
scp -r -F ssh-config controller-1:/etc/kubernetes/pki/ca.key certs/pki
scp -r -F ssh-config controller-1:/etc/kubernetes/pki/sa.pub certs/pki
scp -r -F ssh-config controller-1:/etc/kubernetes/pki/sa.key certs/pki
scp -r -F ssh-config controller-1:/etc/kubernetes/pki/front-proxy-ca.crt certs/pki
scp -r -F ssh-config controller-1:/etc/kubernetes/pki/front-proxy-ca.key certs/pki
scp -r -F ssh-config controller-1:/etc/kubernetes/pki/etcd/ca.crt certs/pki/etcd
scp -r -F ssh-config controller-1:/etc/kubernetes/pki/etcd/ca.key certs/pki/etcd
scp -r -F ssh-config controller-1:/etc/kubernetes/admin.conf config

rm ssh-config

vagrant ssh controller-1 -c "sudo chown -R root:root /etc/kubernetes/pki /etc/kubernetes/admin.conf" 2> /dev/null
