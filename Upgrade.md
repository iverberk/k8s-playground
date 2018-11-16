Step 1. Planing upgrade from 1.11.3 to 1.11.4



    vagrant ssh controller-1
    sudo su
    
    kubeadm upgrade plan
    [preflight] Running pre-flight checks.
    [upgrade] Making sure the cluster is healthy:
    [upgrade/config] Making sure the configuration is correct:
    [upgrade/config] Reading configuration from the cluster...
    [upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
    [upgrade] Fetching available versions to upgrade to
    [upgrade/versions] Cluster version: v1.11.3
    [upgrade/versions] kubeadm version: v1.12.2
    [upgrade/versions] Latest stable version: v1.12.2
    [upgrade/versions] Latest version in the v1.11 series: v1.11.4

    Upgrade to the latest version in the v1.11 series:

    COMPONENT            CURRENT   AVAILABLE
    API Server           v1.11.3   v1.11.4
    Controller Manager   v1.11.3   v1.11.4
    Scheduler            v1.11.3   v1.11.4
    Kube Proxy           v1.11.3   v1.11.4
    CoreDNS              1.2.2     1.2.2
    Etcd                 3.2.18    3.2.18

    You can now apply the upgrade by executing the following command:

        kubeadm upgrade apply v1.11.4

    _____________________________________________________________________

    Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
    COMPONENT   CURRENT       AVAILABLE
    Kubelet     5 x v1.11.4   v1.12.2

    Upgrade to the latest stable version:

    COMPONENT            CURRENT   AVAILABLE
    API Server           v1.11.3   v1.12.2
    Controller Manager   v1.11.3   v1.12.2
    Scheduler            v1.11.3   v1.12.2
    Kube Proxy           v1.11.3   v1.12.2
    CoreDNS              1.2.2     1.2.2
    Etcd                 3.2.18    3.2.24

    You can now apply the upgrade by executing the following command:

        kubeadm upgrade apply v1.12.2

    _____________________________________________________________________