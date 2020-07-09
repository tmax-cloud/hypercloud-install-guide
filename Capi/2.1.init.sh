## install binary about capi
#### clusterawsadm binary install
curl -L https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/download/${AWS_VERSION}/clusterawsadm-linux-amd64 -o clusterawsadm
chmod +x clusterawsadm
mv clusterawsadm /usr/local/bin/clusterawsadm

#### clusterctl binary install
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/${CAPI_VERSION}/clusterctl-linux-amd64 -o clusterctl
chmod +x clusterctl
mv clusterctl /usr/local/bin/clusterctl

## mkdir
#### make yaml dir
if [ ! -d yaml ]; then
    mkdir yaml
    mkdir yaml/_template
    mkdir yaml/_install
fi

#### make image dir for download capi, aws images
if [ ! -d img ]; then
   mkdir img
fi

## download yaml
curl -L http://github.com/kubernetes-sigs/cluster-api/releases/download/"$CAPI_VERSION"/cluster-api-components.yaml > yaml/_template/cluster-api-components-template-${CAPI_VERSION}.yaml 
curl -L https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/download/"${AWS_VERSION}"/infrastructure-components.yaml > yaml/_template/infrastructure-components-aws-template-${AWS_VERSION}.yaml
curl -L https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/download/${AWS_VERSION}/cluster-template.yaml > yaml/_template/cluster-aws-template-${AWS_VERSION}.yaml

## init capi settings
cp yaml/_template/cluster-api-components-template-${CAPI_VERSION}.yaml yaml/_install/1.cluster-api-components-${CAPI_VERSION}.yaml
cp yaml/_template/infrastructure-components-aws-template-${AWS_VERSION}.yaml yaml/_install/2.infrastructure-components-aws-${AWS_VERSION}.yaml

sed -i 's/${AWS_B64ENCODED_CREDENTIALS}/'${AWS_B64ENCODED_CREDENTIALS}'/g' yaml/_install/2.infrastructure-components-aws-${AWS_VERSION}.yaml

echo ""
echo "== init information =="
echo "[system enviroments]"
echo "  AWS_B64ENCODED_CREDENTIALS:" $AWS_B64ENCODED_CREDENTIALS
