## pull image: kubernetes-multicluster/kubefed ##
docker pull quay.io/kubernetes-multicluster/kubefed:$FED_VER
docker save quay.io/kubernetes-multicluster/kubefed:$FED_VER > img/kubefed_$FED_VER.tar
docker load < img/kubefed_$FED_VER.tar
docker tag quay.io/kubernetes-multicluster/kubefed:$FED_VER $REGISTRY/kubernetes-multicluster/kubefed:$FED_VER
docker push $REGISTRY/kubernetes-multicluster/kubefed:$FED_VER
