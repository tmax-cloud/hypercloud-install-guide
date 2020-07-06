kubectl delete ServiceAccount external-dns -n kube-system
kubectl delete ClusterRoleBinding external-dns-viewer -n kube-system
kubectl delete ClusterRole external-dns -n kube-system
kubectl delete deployment external-dns -n kube-system
