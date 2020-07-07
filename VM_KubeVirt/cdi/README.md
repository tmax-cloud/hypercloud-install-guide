# CDI 설치 가이드

## 구성 요소 및 버전

### Default CDI 버전

- [v1.18.0](https://github.com/kubevirt/containerized-data-importer/releases/tag/v1.18.0)

### 도커 이미지 버전

- [kubevirt/cdi-controller:v1.18.0](https://hub.docker.com/layers/kubevirt/cdi-controller/v1.18.0/images/sha256-6b299f2e9e369df47cb0719852a0a215cf839c8bf6fd5e80ad86c1416ec5696b?context=explore)
- [kubevirt/cdi-importer:v1.18.0](https://hub.docker.com/layers/kubevirt/cdi-importer/v1.18.0/images/sha256-fab487728cb01678e6e7f09bae28bc063b2b2f36191820ff1b308ff9f6d74f08?context=explore)
- [kubevirt/cdi-cloner:v1.18.0](https://hub.docker.com/layers/kubevirt/cdi-cloner/v1.18.0/images/sha256-5bc95c4a009bd07d743a120f7816ba6bdf82280824fd5a2c655f13223e1b0b4e?context=explore)
- [kubevirt/cdi-apiserver:v1.18.0](https://hub.docker.com/layers/kubevirt/cdi-apiserver/v1.18.0/images/sha256-c7c1ae718d266fd83ff29907f45ca3f97b2f828e4ccac09bf9a74dfe2f7d0f4a?context=explore)
- [kubevirt/cdi-uploadserver:v1.18.0](https://hub.docker.com/layers/kubevirt/cdi-uploadserver/v1.18.0/images/sha256-77152d2e66d332bfac0abcb7a05c550e20404d0d8c44ee6709fb7a4e153cd6ac?context=explore)
- [kubevirt/cdi-uploadproxy:v1.18.0](https://hub.docker.com/layers/kubevirt/cdi-uploadproxy/v1.18.0/images/sha256-eab971766f92f1e71d78dc425b15d04828fc10e4fbe7b6021c41a906199e6919?context=explore)
- [kubevirt/cdi-operator:v1.18.0](https://hub.docker.com/layers/kubevirt/cdi-operator/v1.18.0/images/sha256-e05c065407733676e01f5ec5deeca4cf93a8d78e9f42d315a20baaa30d6e3216?context=explore)

## Prerequisites

1. 쿠버네티스 클러스터가 구축되어 있어야 합니다.
2. kubectl v1.15 이상 버전이 필요합니다.

## 폐쇄망 설치 가이드

폐쇄망에서 설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 hcsctl 바이너리를 준비합니다.

1. rook 설치 시 필요한 이미지와 바이너리를 다운로드 합니다.
  - 작업 디렉토리 생성 및 환경 설정
  ``` shell
  $ mkdir -p ~/cdi-install
  $ export CDI_HOME=~/cdi-install
  $ export CDI_VERSION=v1.18.0
  $ cd $CDI_VERSION
  ```

  - 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운로드 합니다.
  ```shell
  $ sudo docker pull kubevirt/cdi-controller:${CDI_VERSION}
  $ sudo docker pull kubevirt/cdi-importer:${CDI_VERSION}
  $ sudo docker pull kubevirt/cdi-cloner:${CDI_VERSION}
  $ sudo docker pull kubevirt/cdi-apiserver:${CDI_VERSION}
  $ sudo docker pull kubevirt/cdi-uploadserver:${CDI_VERSION}
  $ sudo docker pull kubevirt/cdi-uploadproxy:${CDI_VERSION}
  $ sudo docker pull kubevirt/cdi-operator:${CDI_VERSION}
  
  $ sudo docker save kubevirt/cdi-controller:${CDI_VERSION} > cdi-controller_${CDI_VERSION}.tar
  $ sudo docker save kubevirt/cdi-importer:${CDI_VERSION} > cdi-importer_${CDI_VERSION}.tar
  $ sudo docker save kubevirt/cdi-cloner:${CDI_VERSION} > cdi-cloner_${CDI_VERSION}.tar
  $ sudo docker save kubevirt/cdi-apiserver:${CDI_VERSION} > cdi-apiserver_${CDI_VERSION}.tar
  $ sudo docker save kubevirt/cdi-uploadserver:${CDI_VERSION} > cdi-uploadserver_${CDI_VERSION}.tar
  $ sudo docker save kubevirt/cdi-uploadproxy:${CDI_VERSION} > cdi-uploadproxy_${CDI_VERSION}.tar
  $ sudo docker save kubevirt/cdi-operator:${CDI_VERSION} > cdi-operator_${CDI_VERSION}.tar
  ```

  - hcsctl binary를 다운로드 합니다.
    - rook 설치 과정에서 이미 다운로드 했다면, 필요하지 않습니다.
  ``` shell
  $ wget https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/rook-ceph/hcsctl # 임시 url, github 으로 hyper-cloud storage 프로젝트 이전 후 업데이트 될 예정입니다.
  ```

2. 위의 과정에서 생성한 tar 파일들을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 이미지를 push 합니다.

``` shell
$ sudo docker load < cdi-controller_${CDI_VERSION}.tar
$ sudo docker load < cdi-importer_${CDI_VERSION}.tar
$ sudo docker load < cdi-cloner_${CDI_VERSION}.tar
$ sudo docker load < cdi-apiserver_${CDI_VERSION}.tar
$ sudo docker load < cdi-uploadserver_${CDI_VERSION}.tar
$ sudo docker load < cdi-uploadproxy_${CDI_VERSION}.tar
$ sudo docker load < cdi-operator_${CDI_VERSION}.tar

$ export REGISTRY=123.456.789.00:5000

$ sudo docker tag kubevirt/cdi-controller:${CDI_VERSION} ${REGISTRY}/kubevirt/cdi-controller:${CDI_VERSION}
$ sudo docker tag kubevirt/cdi-importer:${CDI_VERSION} ${REGISTRY}/kubevirt/cdi-importer:${CDI_VERSION}
$ sudo docker tag kubevirt/cdi-cloner:${CDI_VERSION} ${REGISTRY}/kubevirt/cdi-cloner:${CDI_VERSION}
$ sudo docker tag kubevirt/cdi-apiserver:${CDI_VERSION} ${REGISTRY}/kubevirt/cdi-apiserver:${CDI_VERSION}
$ sudo docker tag kubevirt/cdi-uploadserver:${CDI_VERSION} ${REGISTRY}/kubevirt/cdi-uploadserver:${CDI_VERSION}
$ sudo docker tag kubevirt/cdi-uploadproxy:${CDI_VERSION} ${REGISTRY}/kubevirt/cdi-uploadproxy:${CDI_VERSION}
$ sudo docker tag kubevirt/cdi-operator:${CDI_VERSION} ${REGISTRY}/kubevirt/cdi-operator:${CDI_VERSION}

$ sudo docker push ${REGISTRY}/kubevirt/cdi-controller:${CDI_VERSION}
$ sudo docker push ${REGISTRY}/kubevirt/cdi-importer:${CDI_VERSION}
$ sudo docker push ${REGISTRY}/kubevirt/cdi-cloner:${CDI_VERSION}
$ sudo docker push ${REGISTRY}/kubevirt/cdi-apiserver:${CDI_VERSION}
$ sudo docker push ${REGISTRY}/kubevirt/cdi-uploadserver:${CDI_VERSION}
$ sudo docker push ${REGISTRY}/kubevirt/cdi-uploadproxy:${CDI_VERSION}
$ sudo docker push ${REGISTRY}/kubevirt/cdi-operator:${CDI_VERSION}
```

## Install Steps

0. [cdi yaml 생성](#Step-0-cdi-yaml-생성)
1. [cdi yaml 이미지 정보 수정](#Step-1-cdi-yaml-이미지-정보-수정)
2. [rook & cdi 설치](#Step-2-rook--cdi-설치)
3. [cdi 설치 확인](#Step-3-cdi-설치-확인)
4. [rook & cdi 제거](#Step-4-rook--cdi-제거)

## Step 0. cdi yaml 생성

- 목적 : `hcsctl 바이너리 파일로 cdi 관련 yaml 생성`
- 순서 : 
  - hcsctl 바이너리를 사용하여 inventory를 생성합니다.
    - inventory_name 은 yaml 파일들이 저장될 폴더 이름으로 임의로 지정해주시면 됩니다.
    ``` shell
	$  ./hcsctl create-inventory testInventory --include-cdi
	$ cd {$inventory_name}
	# cdi 와 rook 폴더가 생성 되었음을 확인
	```
- 비고 :
  - [rook 설치 가이드](../../rook-ceph/README.md)를 통해 이미 inventory와 cdi, rook 폴더가 준비된 경우는 해당 스텝은 필요하지 않습니다.

## Step 1. cdi yaml 이미지 정보 수정

- 목적 : `cdi yaml에 이미지 registry 버전 정보를 수정`
- 순서 : 
  - 아래의 command를 수정하여 사용하고자 하는 image 버전 정보를 수정합니다.
  ``` shell
  $ sed -i 's/{cdi_version}/'${CDI_VERSION}'/g'  $inventory_name/cdi/*.yaml
  ```
- 비고 :
  - 폐쇄망에서 설치를 진행하여 별도의 image registry를 사용하는 경우 registry 정보를 추가로 설정해줍니다.
  - 본 프로젝트의 yaml 파일은 storage 관련 pod 들의 docker image 를 받아올 registry 를 적지 않은 상태로 제공됩니다. docker image 가 등록된 private registry 정보를 적용 하셔야 하고, 폐쇄망 설치가 아닐경우, 별도의 hcsctl 바이너리 파일을 안내 받으셔야 합니다. 
  - [rook 설치 가이드](../../rook-ceph/README.md)를 통해 이미 registry 정보 수정이 이루어진 경우에는 아래 작업이 필요하지 않습니다.
  ``` shell
  $ sed -i 's/{registry_endpoint}/'${REGISTRY}'/g' $inventory_name/cdi/*.yaml
  $ sed -i 's/{registry_endpoint}/'${REGISTRY}'/g'  $inventory_name/rook/*.yaml
  ```

## Step 2. rook & cdi 설치

- 목적 : `rook과 cdi 설치`
- 순서 : 
  - ./hcsctl install {$inventory_name}
- 비고 :
  - 생성된 폴더와 파일명은 절대 변경 하시면 안됩니다.
  - [rook 설치 가이드](../../rook-ceph/README.md)를 통해 rook 관련 yaml 파일들의 설치 정보 수정이 사전에 필요합니다.
  - 정상 설치가 완료되면 Block Storage와 Shared Filesystem을 사용할 수 있습니다.

## Step 3. cdi 설치 확인

- 목적 : `rook 설치 확인`
- 순서 : 
  - kubectl get pods -n cdi
  ``` shell
  NAME                               READY   STATUS    RESTARTS   AGE
  cdi-apiserver-9cc9496b8-264xh      1/1     Running   0          5d20h
  cdi-deployment-bc57c59ff-z74s2     1/1     Running   0          5d20h
  cdi-operator-55bfb8b575-r4c4x      1/1     Running   0          5d20h
  cdi-uploadproxy-74d6c4dbcc-z6rvk   1/1     Running   0          5d20h
  ```
  - ./hcsctl.test
    - 정상 사용 가능 여부 확인을 위해, 여러 시나리오 테스트를 수행할 수 있습니다.
    - 약 15분 가량 소요될 수 있습니다.
	- 해당 테스트 중 cdi test는 폐쇄망 환경에서 사용하실 수 없습니다.
- 비고 :
  - 아래 pod 들이 모두 배포되고, status 가 running 인지 확인합니다.
    - cdi-apiserver
    - cdi-deployment
    - cdi-operator
    - cdi-uploadproxy

## Step 4. rook & cdi 제거

- 목적 : `rook과 cdi 제거`
- 순서 : 
  - ./hcsctl uninstall {$inventory_name}
	- hcsctl 로 설치시 사용한 inventory 이름을 명시하여 hypercloud-storage 를 제거합니다.
- 비고 :
  - uninstall 후에 디바이스 초기화 방법은 [rook 설치 가이드](../../rook-ceph/README.md)를 참고 부탁드립니다.
