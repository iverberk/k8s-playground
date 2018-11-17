kubectl apply --kubeconfig=/etc/kubernetes/admin.conf -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter-all-features.yaml
kubectl delete --kubeconfig=/etc/kubernetes/admin.conf -n kube-system ds kube-proxy
