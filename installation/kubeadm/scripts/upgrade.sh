#!/bin/bash -e

if [ -z ${KUBECONFIG+x} ]; then echo "Please make sure that your KUBECONFIG is set"; exit 1; fi
if [ -z ${1+x} ]; then echo "Please provide a version for the upgrade"; exit 1; fi

# This script can be used to upgrade from 1.11 to 1.12

for index in 1 2 3
do

  kubectl get configmap -n kube-system kubeadm-config -o yaml > kubeadm-config.yaml

  # Update the controller name for the api endpoint
  sed -i "s/controller-[1-3]:/controller-$index:/" kubeadm-config.yaml

  # Increment the index to use as network ip
  IP=$((index+1))

  # Adjust Etcd parameters
  sed -i "s#initial-cluster:.*#initial-cluster: controller-1=https://192.168.10.2:2380,controller-2=https://192.168.10.3:2380,controller-3=https://192.168.10.4:2380#" kubeadm-config.yaml
  sed -i "s#advertise-client-urls:.*#advertise-client-urls: https://192.168.10.$IP:2379#" kubeadm-config.yaml
  sed -i "s#initial-advertise-peer-urls:.*#initial-advertise-peer-urls: https://192.168.10.$IP:2380#" kubeadm-config.yaml
  sed -i "s#listen-client-urls:.*#listen-client-urls: https://127.0.0.1:2379,https://192.168.10.$IP:2379#" kubeadm-config.yaml
  sed -i "s#listen-peer-urls:.*#listen-peer-urls: https://192.168.10.$IP:2380#" kubeadm-config.yaml
  sed -i "s#advertiseAddress:.*#advertiseAddress: 192.168.10.$IP#" kubeadm-config.yaml
  grep 'initial-cluster-state: existing' kubeadm-config.yaml &> /dev/null || sed -i -n ' p; s/listen-peer-urls:.*/initial-cluster-state: existing/p' kubeadm-config.yaml

  # Adjust hyperkube image version
  sed -i "s#unifiedControlPlaneImage:.*#unifiedControlPlaneImage: gcr.io/google_containers/hyperkube:v$1#" kubeadm-config.yaml

  kubectl apply -f kubeadm-config.yaml --force

  vagrant ssh controller-$index -c "sudo kubeadm upgrade apply -y v$1"

done

kubectl delete -n kube-system ds kube-proxy

for index in 1 2 3
do
  vagrant ssh controller-$index -c "sudo yum install -y kubelet-$1 && sudo systemctl daemon-reload && sudo systemctl restart kubelet"
done

for index in 1 2
do
  vagrant ssh worker-$index -c "sudo yum install -y kubelet-$1 && sudo systemctl daemon-reload && sudo systemtl restart kubelet"
done

rm -f kubeadm-config.yaml

exit 0
