## pull image: kube-rbac-proxy ##
docker pull gcr.io/kubebuilder/kube-rbac-proxy:$KUBE_RBAC_PROXY_VERSION 
docker save gcr.io/kubebuilder/kube-rbac-proxy:$KUBE_RBAC_PROXY_VERSION > img/kubebuilder_kube-rbac-proxy_$KUBE_RBAC_PROXY_VERSION.tar 
docker load < img/kubebuilder_kube-rbac-proxy_$KUBE_RBAC_PROXY_VERSION.tar 
docker tag gcr.io/kubebuilder/kube-rbac-proxy:$KUBE_RBAC_PROXY_VERSION $REGISTRY/kubebuilder/kube-rbac-proxy:$KUBE_RBAC_PROXY_VERSION
docker push $REGISTRY/kubebuilder/kube-rbac-proxy:$KUBE_RBAC_PROXY_VERSION

## pull images: 1.cluster-api-components.yaml ##
docker pull us.gcr.io/k8s-artifacts-prod/cluster-api/cluster-api-controller:$CAPI_VERSION
docker save us.gcr.io/k8s-artifacts-prod/cluster-api/cluster-api-controller:$CAPI_VERSION > img/cluster-api_cluster-api-controller_$CAPI_VERSION.tar
docker load < img/cluster-api_cluster-api-controller_$CAPI_VERSION.tar
docker tag us.gcr.io/k8s-artifacts-prod/cluster-api/cluster-api-controller:$CAPI_VERSION $REGISTRY/k8s-artifacts-prod/cluster-api/cluster-api-controller:$CAPI_VERSION
docker push $REGISTRY/k8s-artifacts-prod/cluster-api/cluster-api-controller:$CAPI_VERSION

docker pull us.gcr.io/k8s-artifacts-prod/cluster-api/kubeadm-bootstrap-controller:$CAPI_VERSION
docker save us.gcr.io/k8s-artifacts-prod/cluster-api/kubeadm-bootstrap-controller:$CAPI_VERSION > img/cluster-api_kubeadm-bootstrap-controller_$CAPI_VERSION.tar
docker load < img/cluster-api_kubeadm-bootstrap-controller_$CAPI_VERSION.tar
docker tag us.gcr.io/k8s-artifacts-prod/cluster-api/kubeadm-bootstrap-controller:$CAPI_VERSION $REGISTRY/k8s-artifacts-prod/cluster-api/kubeadm-bootstrap-controller:$CAPI_VERSION
docker push $REGISTRY/k8s-artifacts-prod/cluster-api/kubeadm-bootstrap-controller:$CAPI_VERSION

docker pull us.gcr.io/k8s-artifacts-prod/cluster-api/kubeadm-control-plane-controller:$CAPI_VERSION
docker save us.gcr.io/k8s-artifacts-prod/cluster-api/kubeadm-control-plane-controller:$CAPI_VERSION > img/cluster-api_kubeadm-control-plane-controller_$CAPI_VERSION.tar
docker load < img/cluster-api_kubeadm-control-plane-controller_$CAPI_VERSION.tar
docker tag us.gcr.io/k8s-artifacts-prod/cluster-api/kubeadm-control-plane-controller:$CAPI_VERSION $REGISTRY/k8s-artifacts-prod/cluster-api/kubeadm-control-plane-controller:$CAPI_VERSION
docker push $REGISTRY/k8s-artifacts-prod/cluster-api/kubeadm-control-plane-controller:$CAPI_VERSION

## pull images: 3.control-plane-components.yaml ##
docker pull us.gcr.io/k8s-artifacts-prod/cluster-api-aws/cluster-api-aws-controller:$AWS_VERSION
docker save us.gcr.io/k8s-artifacts-prod/cluster-api-aws/cluster-api-aws-controller:$AWS_VERSION > img/cluster-api-aws_cluster-api-aws-controller_$AWS_VERSION.tar
docker load < img/cluster-api-aws_cluster-api-aws-controller_$AWS_VERSION.tar
docker tag us.gcr.io/k8s-artifacts-prod/cluster-api-aws/cluster-api-aws-controller:$AWS_VERSION $REGISTRY/k8s-artifacts-prod/cluster-api-aws/cluster-api-aws-controller:$AWS_VERSION
docker push $REGISTRY/k8s-artifacts-prod/cluster-api-aws/cluster-api-aws-controller:$AWS_VERSION

## change image registry ##
sed -i 's/gcr.io\/kubebuilder\/kube-rbac-proxy:'${KUBE_RBAC_PROXY_VERSION}'/'${REGISTRY}'\/kubebuilder\/kube-rbac-proxy:'${KUBE_RBAC_PROXY_VERSION}'/g' yaml/_install/1.cluster-api-components-${CAPI_VERSION}.yaml
sed -i 's/us.gcr.io\/k8s-artifacts-prod\/cluster-api\/cluster-api-controller:'${CAPI_VERSION}'/'${REGISTRY}'\/k8s-artifacts-prod\/cluster-api\/cluster-api-controller:'${CAPI_VERSION}'/g' yaml/_install/1.cluster-api-components-${CAPI_VERSION}.yaml
sed -i 's/us.gcr.io\/k8s-artifacts-prod\/cluster-api\/kubeadm-bootstrap-controller:'${CAPI_VERSION}'/'${REGISTRY}'\/k8s-artifacts-prod\/cluster-api\/kubeadm-bootstrap-controller:'${CAPI_VERSION}'/g' yaml/_install/1.cluster-api-components-${CAPI_VERSION}.yaml
sed -i 's/us.gcr.io\/k8s-artifacts-prod\/cluster-api\/kubeadm-control-plane-controller:'${CAPI_VERSION}'/'${REGISTRY}'\/k8s-artifacts-prod\/cluster-api\/kubeadm-control-plane-controller:'${CAPI_VERSION}'/g' yaml/_install/1.cluster-api-components-${CAPI_VERSION}.yaml
sed -i 's/us.gcr.io\/k8s-artifacts-prod\/cluster-api-aws\/cluster-api-aws-controller:'${AWS_VERSION}'/'${REGISTRY}'\/k8s-artifacts-prod\/cluster-api-aws\/cluster-api-aws-controller:'${AWS_VERSION}'/g' yaml/_install/2.infrastructure-components-aws-${AWS_VERSION}.yaml
