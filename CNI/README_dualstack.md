
# Calico DualStack CNI 설치 가이드
* Calico CNI를 사용하며, 3.11 이후 버전 사용 필요
* Calicoctl도 함께 설치 진행 필요
    * https://www.projectcalico.org/


## 구성 요소 및 버전
* calico/node ([calico/node:v3.15.1](https://hub.docker.com/layers/calico/node/v3.15.1/images/sha256-30f5e5876d53942465bda40f777b31c2cf4da1ac76884a782e77873f3d780c12?context=explore))
* calico/pod2daemon-flexvol ([calico/pod2daemon-flexvol:v3.15.1](https://hub.docker.com/layers/calico/pod2daemon-flexvol/v3.15.1/images/sha256-180e4a92a556116d2380d02c3c7843a1fc507e9c35986fef4b39cbd6e15dcb00?context=explore))
* calico/cni ([calico/cni:v3.15.1](https://hub.docker.com/layers/calico/cni/v3.15.1/images/sha256-a925b445c2688fc9c149b20ea04faabd40610d3304a6efda68e5dada7a41b813?context=explore))
* calico/kube-controllers ([calico/kube-controllers:v3.15.1](https://hub.docker.com/layers/calico/kube-controllers/v3.15.1/images/sha256-092a53ea4e8d2d4498f0364a160752868169dfadedf7144cd820d6b04ddf4161?context=explore))
* calico/ctl ([calico/ctl:v3.15.0](https://registry.hub.docker.com/layers/calico/ctl/v3.15.0/images/sha256-09a08c8ef2ef637aadb3d2cc46965b8ba73e0e4cf863c836ad114cc3292822aa?context=explore))

## Prerequisites

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. **폐쇄망에서 설치하는 경우** 사용하는 image repository에 CNI 설치 시 필요한 이미지를 push한다. 

    * 작업 디렉토리 생성 및 환경 설정
    ```bash
    $ mkdir -p ~/cni-install
    $ export CNI_HOME=~/cni-install
    $ export CNI_VERSION=v3.15.1
    $ export CTL_VERSION=v3.15.0
    $ export REGISTRY=172.22.8.106:5000
    $ cd $CNI_HOME
    ```

    * 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받는다.
    ```bash
    $ sudo docker pull calico/node:${CNI_VERSION}
    $ sudo docker save calico/node:${CNI_VERSION} > calico-node_${CNI_VERSION}.tar
    $ sudo docker pull calico/pod2daemon-flexvol:${CNI_VERSION}
    $ sudo docker save calico/pod2daemon-flexvol:${CNI_VERSION} > calico-pod2daemon-flexvol_${CNI_VERSION}.tar
    $ sudo docker pull calico/cni:${CNI_VERSION}
    $ sudo docker save calico/cni:${CNI_VERSION} > calico-cni_${CNI_VERSION}.tar
    $ sudo docker pull calico/kube-controllers:${CNI_VERSION}
    $ sudo docker save calico/kube-controllers:${CNI_VERSION} > calico-kube-controllers_${CNI_VERSION}.tar
    $ sudo docker pull calico/ctl:${CTL_VERSION}
    $ sudo docker save calico/ctl:${CTL_VERSION} > calico-ctl_${CTL_VERSION}.tar
    ```

    * calico yaml을 다운로드한다. (대역 설정을 위함)
    ```bash
    $ curl https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/master/CNI/calico_dualstack_v3.15.1.yaml > calico.yaml
    ```

    * calicoctl yaml을 다운로드한다.
    ```bash
    $ curl https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/master/CNI/calicoctl_3.15.0.yaml > calicoctl.yaml
    ```


2. 위의 과정에서 생성한 tar 파일들을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 이미지를 push한다.
    ```bash
    $ sudo docker load < calico-node_${CNI_VERSION}.tar
    $ sudo docker load < calico-pod2daemon-flexvol_${CNI_VERSION}.tar
    $ sudo docker load < calico-cni_${CNI_VERSION}.tar
    $ sudo docker load < calico-kube-controllers_${CNI_VERSION}.tar
    $ sudo docker load < calico-ctl_${CTL_VERSION}.tar
    
    $ sudo docker tag calico/node:${CNI_VERSION} ${REGISTRY}/calico/node:${CNI_VERSION}
    $ sudo docker tag calico/pod2daemon-flexvol:${CNI_VERSION} ${REGISTRY}/calico/pod2daemon-flexvol:${CNI_VERSION}
    $ sudo docker tag calico/cni:${CNI_VERSION} ${REGISTRY}/calico/cni:${CNI_VERSION}
    $ sudo docker tag calico/kube-controllers:${CNI_VERSION} ${REGISTRY}/calico/kube-controllers:${CNI_VERSION}
    $ sudo docker tag calico/ctl:${CTL_VERSION} ${REGISTRY}/calico/ctl:${CTL_VERSION}
   
    $ sudo docker push ${REGISTRY}/calico/node:${CNI_VERSION}
    $ sudo docker push ${REGISTRY}/calico/pod2daemon-flexvol:${CNI_VERSION}
    $ sudo docker push ${REGISTRY}/calico/cni:${CNI_VERSION}
    $ sudo docker push ${REGISTRY}/calico/kube-controllers:${CNI_VERSION}
    $ sudo docker push ${REGISTRY}/calico/ctl:${CTL_VERSION}
    ```


## Install Steps
0. [calico.yaml 수정](#step0 "step0")
1. [calico 설치](#step1 "step1")
2. [calicoctl 설치](#step2 "step2")


<h2 id="step0"> Step0. calico yaml 수정 </h2>

* 목적 : `calico yaml에 이미지 registry, 버전 정보, pod 대역, IPIP모드 여부를 수정`
* 생성 순서 : 
    * 아래의 command를 수정하여 사용하고자 하는 image 버전 정보를 수정한다. (기본 설정 버전은 v3.15.1) (듀얼스택 기능은 v3.13 이상에서 지원)
	```bash
            sed -i 's/v3.15.1/'${CNI_VERSION}'/g' calico.yaml
	```
    * ipam config에 ipv4, ipv6 주소 할당 설정을 아래와 같이 수정한다.
  ```bash
  cni_network_config: |-
    {
      "name": "k8s-pod-network",
      "cniVersion": "0.3.1",
      "plugins": [
        {
          "type": "calico",
          "log_level": "info",
          "datastore_type": "kubernetes",
          "nodename": "__KUBERNETES_NODE_NAME__",
          "mtu": __CNI_MTU__,
          "ipam": {
              "type": "calico-ipam",
              "assign_ipv4": "true",
              "assign_ipv6": "true"
          },
 ```

    * pod 대역과 IPIP 모드를 아래와 같이 수정한다. pod 대역은 kubernetes 설치할때 사용했던 kubeadm-config.yaml의 podSubnet 대역과 동일해야 한다. (다를 경우 문제 발생)
	```bash
            - name: CALICO_IPV4_IPPOOL_IPIP
            value: "Never"            
            - name: CALICO_IPV4POOL_CIDR
            value: "10.0.0.0/16" 
	```   
    * Felix의 IPv6 지원에 대한 플래그 활성화, pod IPv6 주소 대역을 수정, 노드 IPv6 주소 감지를 설정
  ```bash
            - name: FELIX_IPV6SUPPORT
              value: "true"
            - name: CALICO_IPV6POOL_CIDR
              value: "fd00:10:20::/72"
            - name: IP6
              value: "autodetect"
  ```

    * master 노드에만 calico-kube-controllers를 띄우기 위해서는 아래와 같은 스케쥴링 옵션을 추가한다. (calico_v.3.13.4_master.yaml 파일 참고)
        * 주의) matchExpressions의 key(kubernetes.io/hostname)의 values에 master 노드의 이름으로 수정
	```bash
        - key: node-role.kubernetes.io/master
          effect: NoSchedule

      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 1
            preference:
              matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                  - kube4

          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: node-role.kubernetes.io/master
                    operator: Exists
	```         
 
* 비고 :
    * `폐쇄망에서 설치를 진행하여 별도의 image registry를 사용하는 경우 registry 정보를 추가로 설정해준다.`
	```bash
            sed -i 's/calico\/cni/'${REGISTRY}'\/calico\/cni/g' calico.yaml
            sed -i 's/calico\/pod2daemon-flexvol/'${REGISTRY}'\/calico\/pod2daemon-flexvol/g' calico.yaml
            sed -i 's/calico\/node/'${REGISTRY}'\/calico\/node/g' calico.yaml
            sed -i 's/calico\/kube-controllers/'${REGISTRY}'\/calico\/kube-controllers/g' calico.yaml
            sed -i 's/calico\/ctl/'${REGISTRY}'\/calico\/ctl/g' calicoctl.yaml
	```

<h2 id="step1"> Step 1. calico 설치 </h2>

* 목적 : `calico 설치`
* 생성 순서: calico.yaml 설치  `ex) kubectl apply -f calico.yaml`
* 비고 :
    * calico-kube-controllers-xxxxxxxxxx-xxxxx (1개의 pod)
    * calico-node-xxxxx (모든 노드에 pod)


<h2 id="step1"> Step 2. calicoctl 설치 </h2>

* 목적 : `calicoctl 설치`
* 생성 순서: calicoctl.yaml 설치  `ex) kubectl apply -f calicoctl.yaml`
* 비고 :
    * kube-system 네임스페이스 사용
    * calicoctl (1개의 pod)
    * alias calicoctl="kubectl exec -i -n kube-system calicoctl /calicoctl -- "


## calico 장애 해결
* 목적 : `calico에서 calico-node pod이 안뜸`
* 해결 방법 : 
    * calicoctl get node 노드이름 -o yaml
        * bgp:ipv4Address 확인 (노드에 인터페이스 여러개 존재하는 경우 변경 필요)
    ```bash
    calicoctl replace -f -<< EOF
    apiVersion: projectcalico.org/v3
    kind: Node
    metadata:
      name: c1-1
    spec:
      bgp:
        ipv4Address: 172.22.8.106
    EOF
    ```



