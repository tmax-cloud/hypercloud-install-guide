## generate federation yaml
cp yaml/template/install.yaml yaml/install-${FED_VER}.yaml 

## replace parameters
sed -i 's/quay.io\/kubernetes-multicluster\/kubefed:${FED_VER}/'${REGISTRY}'\/kubernetes-multicluster\/kubefed:${FED_VER}/g' yaml/install-${FED_VER}.yaml
sed -i 's/${FED_NS}/'${FED_NS}'/g' yaml/install-${FED_VER}.yaml
sed -i 's/${FED_VER}/'${FED_VER}'/g' yaml/install-${FED_VER}.yaml

kubectl apply -f yaml/crd.yaml
kubectl apply -f yaml/install-${FED_VER}.yaml
