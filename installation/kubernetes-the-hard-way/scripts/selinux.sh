echo "Disabling SELinux..."
echo "SELINUX=disabled" > /etc/selinux/config
setenforce 0
