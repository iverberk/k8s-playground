ETCD_VERSION=v3.3.10

echo "Installing etcd binaries..."
cp /vagrant/bin/etcd* /usr/local/bin/
chmod +x /usr/local/bin/etcd*

echo "Configuring etcd..."
mkdir -p /etc/etcd /var/lib/etcd

cp /vagrant/scripts/systemd/etcd.service /etc/systemd/system/etcd.service

ETCD_NAME=$(hostname -s)
sed -i s/%ETCD_NAME%/$ETCD_NAME/g /etc/systemd/system/etcd.service

IP=$(hostname -I | cut -d' ' -f2)
sed -i s/%IP%/$IP/g /etc/systemd/system/etcd.service

echo "Starting etcd..."
systemctl daemon-reload
systemctl enable etcd
systemctl start etcd
