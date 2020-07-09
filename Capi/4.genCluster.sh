## generate capi cluster yaml

## 1. copy from cluster template
cp yaml/_template/cluster-aws-template-${AWS_VERSION}.yaml yaml/cluster-aws.yaml

##replace parameters
sed -i 's/${AWS_REGION}/'${AWS_REGION}'/g' yaml/cluster-aws.yaml
sed -i 's/${AWS_SSH_KEY_NAME}/'${AWS_SSH_KEY_NAME}'/g' yaml/cluster-aws.yaml
sed -i 's/${AWS_CONTROL_PLANE_MACHINE_TYPE}/'${AWS_CONTROL_PLANE_MACHINE_TYPE}'/g' yaml/cluster-aws.yaml
sed -i 's/${AWS_NODE_MACHINE_TYPE}/'${AWS_NODE_MACHINE_TYPE}'/g' yaml/cluster-aws.yaml

sed -i 's/${CLUSTER_NAME}/'$1'/g' yaml/cluster-aws.yaml
sed -i 's/${KUBERNETES_VERSION}/'$2'/g' yaml/cluster-aws.yaml
sed -i 's/${CONTROL_PLANE_MACHINE_COUNT}/'$3'/g' yaml/cluster-aws.yaml
sed -i 's/${WORKER_MACHINE_COUNT}/'$4'/g' yaml/cluster-aws.yaml

kubectl apply -f yaml/cluster-aws.yaml

echo ""
echo "== genCluster information =="
echo "[system enviroments]"
echo "  AWS_REGION:" $AWS_REGION
echo "  AWS_SSH_KEY_NAME:" $AWS_SSH_KEY_NAME
echo "  AWS_CONTROL_PLANE_MACHINE_TYPE:" $AWS_CONTROL_PLANE_MACHINE_TYPE
echo "  AWS_NODE_MACHINE_TYPE:" $AWS_NODE_MACHINE_TYPE
echo "[input parameters]"
echo "  cluster name:" $1
echo "  kubernetes version:" $2
echo "  number of master:" $3
echo "  number of worker:" $3
echo ""
