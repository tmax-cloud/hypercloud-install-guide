kubectl delete federatedtypeconfig -n kube-federation-system --all
kubectl delete -f yaml/install-${FED_VER}.yaml
kubectl delete -f yaml/crd.yaml
