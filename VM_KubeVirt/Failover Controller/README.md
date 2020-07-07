# KubeVirt Node Fail Controller

This controller is a simple controller for KubeVirt Failover.

This documentation contains information about **`the controller binary`** and **`how to install controller to k8s cluster`**.

## About

KubeVirt controller dosen't recreate virt-launcher before the virt-launcher pod on the failed node is deleted completely.

So, we can use this controller to make virt-controller to recovery VMI and virt-launcher container on the failed node.

Watching virt-launcher pods status, it detects pods having Terminating status and **`'tmax/virt-auto-failover="true"'`** label. And it checks Node and VMI ready status are unknown/false. It means that nodes failed, and the virt-launcher pod was evicted. So this controller deletes the VMI forcingly connected the virt-launcher pod.

## How to set your VM to be auto-recreated on node fail situation

If you want your virt-launcher pods and VMIs to be recreate on node fail situation automatically, you must
1. only use PVC having `"Access Modes:ReadWriteMany"`.
2. add the label below to your VM description.
3. add live-restore configuration to docker configuration.


**Label**: If you want your virt-launcher pods and VMIs to be recreate on node fail situation automatically, you must add

    tmax/virt-auto-failover="true"

**Label Location Example**: put the given label into `"spec.template.metadata.labels"`

```apiVersion: kubevirt.io/v1alpha3
kind: VirtualMachine
metadata:
  name: testvm
spec:
  running: false
  template:
    metadata:
      labels:
        kubevirt.io/size: small
        kubevirt.io/domain: testvm
        tmax/virt-auto-failover: "true" # this is it!!!
```
## How to add live-restore on docker Config

**path**:

  /etc/docker/daemon.json

**Contents**:

```
{
  "live-restore": true
}
```

**Apply**:

  systemctl reload docker


## About Calico User-set IP

If you set calico user-set IP, this controller release it from the failed virt-launcher pod, before delete VMI to make a new virt-launcher pod can use the same user-set IP.

**`Only one IP is surported.`**

**Calico User-set IP Setting Example**

```
apiVersion: kubevirt.io/v1alpha3
kind: VirtualMachine
metadata:
  name: vm-sample
  annotations:
    cni.projectcalico.org/ipAddrs: "[\"10.244.235.169\"]" # this is it!!!
```

## How to download install files including image, k8s controller install yaml

You can download docker image having this controller binary by version from 192.168.1.150 sftp server.

**path**:

    /home/ck-ftp/binary/ck3-hypercloud/kubevirt/kubevirt-node-fail-controller/kubevirt-node-fail-controller-${version number}

**files**:

    kubevirt-node-fail-controller.tar  # docker image tar file
    kubevirt-node-fail-controller.yaml  # k8s cluster install yaml
    README.md

**Important**: kubevirt-node-fail-controller.yaml include a specific image version

## How to import docker image using tar file

Use the command below. You must use load command.

```sh
sudo docker load -i kubevirt-node-fail-controller.tar
```

## How to install this controller to k8s cluster
**Component & Version**:

* failover-controller([tmaxcloudck/kube-failover-controller:v1.0](https://hub.docker.com/layers/tmaxcloudck/kube-failover-controller/v1.0/images/sha256-537c04aa66e99fff283151a2de6afba1f17810cfef14e4ff21e785da9de93da2?context=repo))

**Prerequisite**:

1. Since the sample-controller uses `apps/v1` deployments, the Kubernetes cluster version should be greater than 1.9.
2. This Controller is tested on K8S 1.16.3 version, Kubevirt 0.26 version environment.
3. import controller docker image before kubectl apply
4. This yaml is used for 'root' user

## Environment

```sh
$ export FAILOVER_VERSION=v1.0
$ export DOCKER_REGISTRY=${docker_registry}
```

## Closed Network Installation:

1. [Build image]()
2. [Deploy the image to docker registry]()
3. [Apply the Failover Controller]()

## Build binary & image

```sh
# change working directory having main.go
cd src/controller/

# build
go build

cd src/controller/

docker build --tag kubevirt-node-fail-controller:${FAILOVER_VERSION} .

```

## Deploy the image to docker registry

```sh
docker tag kubevirt-node-fail-controller:${FAILOVER_VERSION} ${DOCKER_REGISTRY}/kubevirt-node-fail-controller:${FAILOVER_VERSION}

docker push ${DOCKER_REGISTRY}/kubevirt-node-fail-controller:${FAILOVER_VERSION}

```

## Apply the Failover Controller

```sh

cd ../../manifests/

sed -i "s/kubevirt-node-fail-controller:%VERSION%/$DOCKER_REGISTRY\/kubevirt-node-fail-controller:$FAILOVER_VERSION/g" kubevirt-node-fail-controller.yaml

kubectl apply -f kubevirt-node-fail-controller.yaml
```

## Cleanup

You can clean up the created Controller with:

    kubectl delete -f manifests/kubevirt-node-fail-controller.yaml

## Contact

Tmax A&C, CK3-1 Team
```
Taesun Lee <taesun_lee@tmax.co.kr>, Haemyung Yang <haemyung_yang@tmax.co.kr>, Joowon Cheong <joowon_cheong@tmax.co.kr>
```