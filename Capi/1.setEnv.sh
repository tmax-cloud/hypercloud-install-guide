## set 1.1.init.sh & 1.2.setPrivate.sh ENV
export CAPI_VERSION=v0.3.6
export AWS_VERSION=v0.5.5-alpha.0
export KUBE_RBAC_PROXY_VERSION=v0.4.1

export AWS_REGION=us-east-1
export AWS_ACCESS_KEY_ID=AKIAQDF4RKX2ZSXN25H3
export AWS_SECRET_ACCESS_KEY=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

export REGISTRY=172.21.6.2:5000

clusterawsadm bootstrap iam create-cloudformation-stack
export AWS_B64ENCODED_CREDENTIALS=$(clusterawsadm bootstrap credentials encode-as-profile)

## set 2.genCluster.sh ENV
export AWS_SSH_KEY_NAME=default
export AWS_CONTROL_PLANE_MACHINE_TYPE=t3.large
export AWS_NODE_MACHINE_TYPE=t3.large
