kubectl apply --kubeconfig=/etc/kubernetes/admin.conf -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter-all-features.yaml
kubectl delete --kubeconfig=/etc/kubernetes/admin.conf -n kube-system ds kube-proxy
#docker run --privileged -v /lib/modules:/lib/modules --net=host k8s.gcr.io/kube-proxy-amd64:v1.12.2 kube-proxy --cleanup
