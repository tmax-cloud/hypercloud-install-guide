# Rook 설치 가이드

## 구성 요소 및 버전

### Default rook-ceph 버전

- [v1.3.6](https://github.com/rook/rook/releases/tag/v1.3.6)

### 도커 이미지 버전

- [ceph/ceph:v14.2.9](https://hub.docker.com/layers/ceph/ceph/v14.2.9/images/sha256-3fdd788a3e3016ad546fed2f7edbce04613a9b401ee4dd959ed05b263cb0000f?context=explore)
- [rook/ceph:v1.3.6](https://hub.docker.com/layers/rook/ceph/v1.3.6/images/sha256-db07a76e3acede4f08f95d91321106aa8081e1cb8b17a65d03dd195bdf8f0040?context=explore)
- [quay.io/cephcsi/cephcsi:v2.1.2](https://quay.io/repository/cephcsi/cephcsi?tag=canary&tab=tags)
- [quay.io/k8scsi/csi-node-driver-registrar:v1.2.0](https://quay.io/repository/k8scsi/csi-node-driver-registrar?tag=latest&tab=tags)
- [quay.io/k8scsi/csi-resizer:v0.4.0](https://quay.io/repository/k8scsi/csi-resizer?tab=tags)
- [quay.io/k8scsi/csi-provisioner:v1.4.0](https://quay.io/repository/k8scsi/csi-provisioner?tab=tags)
- [quay.io/k8scsi/csi-snapshotter:v1.2.2](https://quay.io/repository/k8scsi/csi-snapshotter?tab=tags)
- [quay.io/k8scsi/csi-attacher:v2.1.0](https://quay.io/repository/k8scsi/csi-attacher?tab=tags)

## Prerequisites

1. 쿠버네티스 클러스터가 구축되어 있어야 합니다.
2. kubectl v1.15 이상 버전이 필요합니다.
3. 하드웨어 사양 확인이 필요합니다.
  - **production용으로 배포될 경우 해당 사항들을 반드시 지켜주셔야 ceph가 정상적인 성능 및 안정성을 제공합니다.**
  - 또한 사양 확인시에 설치될 노드의 하드웨어 정보들을 별도로 메모해두실 것을 권장합니다.
    - 설치전 yaml 파일 수정 단계에서 `cluster.yaml` 파일과 `file_system.yaml` 파일의 `spec` 아래 resource 설정하는 부분에 ceph pod 들이 사용할 resource의 limit과 request 값을 하드웨어 사양에 맞춰서 설정해주셔야 합니다. 이와 관련해서 아래에 좀 더 자세한 설명이 있습니다.
  - `OSD` 관련 요건
    - CPU: 2GHz CPU 2 core 이상 권장
	- Memory: 최소 2GB + 1TB당 1GB 이상의 메모리 권장
	  - ex) 2TB disk 기반 OSD -> 4GB(2GB+2GB) memory 이상 권장
    - Disk: 최소 10GB 이상 디스크 권장, 데이터 저장용으로 큰 용량의 디바이스를 사용하는 게 좋음
  - `MON` 관련 요건
    - CPU: 2GHz CPU 1 core 이상 권장
	- Memory: 2GB 메모리 이상 권장
	- Disk: 10GB 디스크 이상 권장
  - `MGR` 관련 요건
    - CPU: 2GHz CPU 1 core 이상 권장
    - Memory: 1GB 메모리 이상 권장
  - `MDS` 관련 요건
    - CPU: 2GHz CPU 4 core 이상 권장
    - Memory: 4GB 메모리 이상 권장
4. 권장사항 확인이 필요합니다.
  - 각 노드마다 OSD를 배포하도록 권장 (Taint 걸린 host 없는 걸 확인해야함)
  - 총 OSD 개수는 3개 이상으로 권장
  - CephFS 및 RBD pool 설정 시 Replication 개수 3개 권장
5. ntp 패키지 설치 및 설정이 필요합니다.

``` shell
# ntp 설치
$ yum install ntp
# ntp 설정
$ vi /etc/ntp.conf 
  # 기존 서버 목록은 주석 처리
  #server 0.rhel.pool.ntp.org iburst
  #server 1.rhel.pool.ntp.org iburst
  #server 2.rhel.pool.ntp.org iburst
  #server 3.rhel.pool.ntp.org iburst
  
  # 한국 공용 타임서버 목록 설정
  server 1.kr.pool.ntp.org
  server 0.asia.pool.ntp.org
  server 2.asia.pool.ntp.org
  
  # 폐쇄망인 경우, 노드 중 ntp 서버를 하나 지정하여 설정
  # 내부 네트워크 대역에서 해당 서버를 타임서버로 참조하기 위한 설정
  restrict 192.168.100.0 mask 255.255.255.0 nomodify notrap
  server 127.127.1.0 # local clock
  
  # 폐쇄망인 경우, ntp client 설정
  # client 서버들은 위의 지정된 서버 ip를 사용
  server 192.168.100.120
  
# ntp 서비스 시작
$ systemctl start ntpd
# 노드 재부팅 후에도 자동으로 시작할 수 있도록 설정
$ systemctl enable ntpd
# ntp 작동 여부 확인
$ ntpq -p
```

## 폐쇄망 설치 가이드

폐쇄망에서 설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 hcsctl 바이너리를 준비합니다.

1. rook 설치 시 필요한 이미지와 바이너리를 다운로드 합니다.
  - 작업 디렉토리 생성 및 환경 설정
  ``` shell
  $ mkdir -p ~/rook-install
  $ export ROOK_HOME=~/rook-install
  $ export CEPH_VERSION=v14.2.9
  $ export ROOK_VERSION=v1.3.6
  $ export CEPHCSI_VERSION=v2.1.2
  $ export NODE_DRIVER_VERSION=v1.2.0
  $ export RESIZER_VERSION=v0.4.0
  $ export PROVISIONER_VERSION=v1.4.0
  $ export SNAPSHOTTER_VERSION=v1.2.2
  $ export ATTACHER_VERSION=v2.1.0
  $ cd $ROOK_HOME
  ```

  - 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운로드 합니다.
  ```shell
   $ sudo docker pull ceph/ceph:${CEPH_VERSION}
   $ sudo docker pull rook/ceph:${ROOK_VERSION}
   $ sudo docker pull quay.io/cephcsi/cephcsi:${CEPHCSI_VERSION}
   $ sudo docker pull quay.io/k8scsi/csi-node-driver-registrar:${NODE_DRIVER_VERSION}
   $ sudo docker pull quay.io/k8scsi/csi-resizer:${RESIZER_VERSION}
   $ sudo docker pull quay.io/k8scsi/csi-provisioner:${PROVISIONER_VERSION}
   $ sudo docker pull quay.io/k8scsi/csi-snapshotter:${SNAPSHOTTER_VERSION}
   $ sudo docker pull quay.io/k8scsi/csi-attacher:${ATTACHER_VERSION}

   $ sudo docker save ceph/ceph:${CEPH_VERSION} > ceph_${CEPH_VERSION}.tar
   $ sudo docker save rook/ceph:${ROOK_VERSION} > rook-ceph_${ROOK_VERSION}.tar
   $ sudo docker save quay.io/cephcsi/cephcsi:${CEPHCSI_VERSION} > cephcsi_${CEPHCSI_VERSION}.tar
   $ sudo docker save quay.io/k8scsi/csi-node-driver-registrar:${NODE_DRIVER_VERSION} > csi-node-driver-registrar_${NODE_DRIVER_VERSION}.tar
   $ sudo docker save quay.io/k8scsi/csi-resizer:${RESIZER_VERSION} > csi-resizer_${RESIZER_VERSION}.tar
   $ sudo docker save quay.io/k8scsi/csi-provisioner:${PROVISIONER_VERSION} > csi-provisioner_${PROVISIONER_VERSION}.tar
   $ sudo docker save quay.io/k8scsi/csi-snapshotter:${SNAPSHOTTER_VERSION} > csi-snapshotter_${SNAPSHOTTER_VERSION}.tar
   $ sudo docker save quay.io/k8scsi/csi-attacher:${ATTACHER_VERSION} > csi-attacher_${ATTACHER_VERSION}.tar
  ```

  - hcsctl binary를 다운로드 합니다.
  ``` shell
  $ wget https://github.com/tmax-cloud/hypercloud-install-guide/raw/master/rook-ceph/hcsctl # 임시 url, github 으로 hyper-cloud storage 프로젝트 이전 후 업데이트 될 예정입니다.
  ```

  - `cluster.yaml` [설정 안내 파일](https://github.com/tmax-cloud/hypercloud-storage/blob/master/docs/ceph-cluster-setting.md)을 다운로드 합니다.
  - `block_pool.yaml`, `block_sc.yaml` [설정 안내 파일](https://github.com/tmax-cloud/hypercloud-storage/blob/master/docs/block.md)을 다운로드 합니다.
  - `file_system.yaml`, `file_sc.yaml` [설정 안내 파일](https://github.com/tmax-cloud/hypercloud-storage/blob/master/docs/file.md)을 다운로드 합니다.
  - 메타데이터 바이스 분리 요건이 있는 경우, `cluster.yaml` 설정시 참고할 [안내 파일](https://github.com/tmax-cloud/hypercloud-storage/blob/master/docs/cluster-tuning.md)을 다운로드 합니다.
  - 설정이 필요한 해당 yaml 파일들은 hcsctl 사용하여 inventory create 시에 생성 되며, `$inventory_name/rook/` 경로에서 찾으실 수 있습니다.
  ``` shell
  $ wget https://github.com/tmax-cloud/hypercloud-storage/raw/master/docs/ceph-cluster-setting.md
  $ wget https://github.com/tmax-cloud/hypercloud-storage/raw/master/docs/block.md
  $ wget https://github.com/tmax-cloud/hypercloud-storage/raw/master/docs/file.md
  $ wget https://github.com/tmax-cloud/hypercloud-storage/raw/master/docs/cluster-tuning.md
  ```

2. 위의 과정에서 생성한 tar 파일들을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 이미지를 push 합니다.

``` shell
$ sudo docker load < ceph_${CEPH_VERSION}.tar
$ sudo docker load < rook-ceph_${ROOK_VERSION}.tar
$ sudo docker load < cephcsi_${CEPHCSI_VERSION}.tar
$ sudo docker load < csi-node-driver-registrar_${NODE_DRIVER_VERSION}.tar
$ sudo docker load < csi-resizer_${RESIZER_VERSION}.tar
$ sudo docker load < csi-provisioner_${PROVISIONER_VERSION}.tar
$ sudo docker load < csi-snapshotter_${SNAPSHOTTER_VERSION}.tar
$ sudo docker load < csi-attacher_${ATTACHER_VERSION}.tar

$ export REGISTRY=123.456.789.00:5000

$ sudo docker tag ceph/ceph:${CEPH_VERSION} ${REGISTRY}/ceph/ceph:${CEPH_VERSION}
$ sudo docker tag rook/ceph:${ROOK_VERSION} ${REGISTRY}/rook/ceph:${ROOK_VERSION}
$ sudo docker tag quay.io/cephcsi/cephcsi:${CEPHCSI_VERSION} ${REGISTRY}/cephcsi/cephcsi:${CEPHCSI_VERSION}
$ sudo docker tag quay.io/k8scsi/csi-node-driver-registrar:${NODE_DRIVER_VERSION} ${REGISTRY}/k8scsi/csi-node-driver-registrar:${NODE_DRIVER_VERSION}
$ sudo docker tag quay.io/k8scsi/csi-resizer:${RESIZER_VERSION} ${REGISTRY}/k8scsi/csi-resizer:${RESIZER_VERSION}
$ sudo docker tag quay.io/k8scsi/csi-provisioner:${PROVISIONER_VERSION} ${REGISTRY}/k8scsi/csi-provisioner:${PROVISIONER_VERSION}
$ sudo docker tag quay.io/k8scsi/csi-snapshotter:${SNAPSHOTTER_VERSION} ${REGISTRY}/k8scsi/csi-snapshotter:${SNAPSHOTTER_VERSION}
$ sudo docker tag quay.io/k8scsi/csi-attacher:${ATTACHER_VERSION} ${REGISTRY}/k8scsi/csi-attacher:${ATTACHER_VERSION}

$ sudo docker push ${REGISTRY}/ceph/ceph:${CEPH_VERSION}
$ sudo docker push ${REGISTRY}/rook/ceph:${ROOK_VERSION}
$ sudo docker push ${REGISTRY}/cephcsi/cephcsi:${CEPHCSI_VERSION}
$ sudo docker push ${REGISTRY}/k8scsi/csi-node-driver-registrar:${NODE_DRIVER_VERSION}
$ sudo docker push ${REGISTRY}/k8scsi/csi-resizer:${RESIZER_VERSION}
$ sudo docker push ${REGISTRY}/k8scsi/csi-provisioner:${PROVISIONER_VERSION}
$ sudo docker push ${REGISTRY}/k8scsi/csi-snapshotter:${SNAPSHOTTER_VERSION}
$ sudo docker push ${REGISTRY}/k8scsi/csi-attacher:${ATTACHER_VERSION}
```

## Install Steps

0. [rook yaml 생성](#Step-0-rook-yaml-생성)
1. [rook yaml 이미지 정보 수정](#Step-1-rook-yaml-이미지-정보-수정)
2. [rook yaml 설치 정보 수정](#Step-2-rook-yaml-설치-정보-수정)
3. [rook 설치](#Step-3-rook-설치)
4. [rook 설치 확인](#Step-4-rook-설치-확인)
5. [rook 제거](#Step-5-rook-제거)

## Step 0. rook yaml 생성

- 목적 : `hcsctl 바이너리 파일로 rook 관련 yaml 생성`
- 순서 : 
  - hcsctl 바이너리를 사용하여 inventory를 생성합니다.
    - inventory_name 은 yaml 파일들이 저장될 폴더 이름으로 임의로 지정해주시면 됩니다.
	``` shell
	$ ./hcsctl create-inventory {$inventory_name}
	$ cd {$inventory_name}
	# rook 폴더가 생성 되었음을 확인
	```
	- VM image가 필요하여 CDI도 함께 설치할 경우에는 아래와 같이옵션 설정을 해주시면 됩니다.
	  - 단 이경우, [CDI 가이드](../VM_KubeVirt/cdi/README.md)도 참고하여 CDI 이미지 또한 준비한 후, 설치진행 해주시길 바랍니다.
	``` shell
	$  ./hcsctl create-inventory testInventory --include-cdi
	$ cd {$inventory_name}
	# cdi 와 rook 폴더가 생성 되었음을 확인
	```

## Step 1. rook yaml 이미지 정보 수정

- 목적 : `rook yaml에 이미지 registry 버전 정보를 수정`
- 순서 : 
  - 아래의 command를 수정하여 사용하고자 하는 image 버전 정보를 수정합니다.
  ``` shell
  $ sed -i 's/{ceph_version}/'${CEPH_VERSION}'/g'  $inventory_name/rook/*.yaml
  $ sed -i 's/{cephcsi_version}/'${CEPHCSI_VERSION}'/g'  $inventory_name/rook/*.yaml
  $ sed -i 's/{node_driver_version}/'${NODE_DRIVER_VERSION}'/g' $inventory_name/rook/*.yaml
  $ sed -i 's/{resizer_version}/'${RESIZER_VERSION}'/g'  $inventory_name/rook/*.yaml
  $ sed -i 's/{provisioner_version}/'${PROVISIONER_VERSION}'/g' $inventory_name/rook/*.yaml
  $ sed -i 's/{snapshotter_version}/'${SNAPSHOTTER_VERSION}'/g' $inventory_name/rook/*.yaml
  $ sed -i 's/{attacher_version}/'${ATTACHER_VERSION}'/g'  $inventory_name/rook/*.yaml
  $ sed -i 's/{rook_version}/'${ROOK_VERSION}'/g'  $inventory_name/rook/*.yaml
  ```
- 비고 :
  - 폐쇄망에서 설치를 진행하여 별도의 image registry를 사용하는 경우 registry 정보를 추가로 설정해줍니다.
  ``` shell
  $ sed -i 's/{registry_endpoint}/'${REGISTRY}'/g'  $inventory_name/rook/*.yaml
  $ sed -i 's/{registry_endpoint}/'${REGISTRY}'/g' $inventory_name/cdi/*.yaml # cdi 설치도 함께하는 경우
  ```
  - 본 프로젝트의 yaml 파일은 storage 관련 pod 들의 docker image 를 받아올 registry 를 적지 않은 상태로 제공됩니다. docker image 가 등록된 private registry 정보를 적용 하셔야 하고, 폐쇄망 설치가 아닐경우, 별도의 hcsctl 바이너리 파일을 안내 받으셔야 합니다. 

## Step 2. rook yaml 설치 정보 수정

- 목적 : `설치 환경에 맞춰서 rook 폴더 밑의 yaml 파일 수정`
- 순서 : 
  - `cluster.yaml` [설정 안내 파일](https://github.com/tmax-cloud/hypercloud-storage/blob/master/docs/ceph-cluster-setting.md)을 참고하여 해당 yaml 파일 수정이 필요합니다.
  - `block_pool.yaml`, `block_sc.yaml` [설정 안내 파일](https://github.com/tmax-cloud/hypercloud-storage/blob/master/docs/block.md)을 참고하여 해당 yaml 파일 수정이 필요합니다.
  - `file_system.yaml`, `file_sc.yaml` [설정 안내 파일](https://github.com/tmax-cloud/hypercloud-storage/blob/master/docs/file.md)을 참고하여 해당 yaml 파일 수정이 필요합니다.
  - 메타데이터 바이스 분리 요건이 있는 경우, 참고할 [설정 안내 파일](https://github.com/tmax-cloud/hypercloud-storage/blob/master/docs/cluster-tuning.md)을 바탕으로 `cluster.yaml` 설정이 필요합니다.
- 비고 :
  - 생성된 폴더와 파일명은 절대 변경 하시면 안됩니다.
  - 설정 안내는 각 링크 참고 부탁드립니다.
  - 폐쇄망 설치시 설정 안내는 사전에 다운로드 받으신 각 파일을 참고 부탁드립니다.

## Step 3. rook 설치

- 목적 : `rook 설치`
- 순서 : 
  - ./hcsctl install {$inventory_name}
- 비고 :
  - CDI도 설치가 필요한 경우, [CDI 가이드](../VM_KubeVirt/cdi/README.md) 도 참고하여 준비된 CDI 이미지 정보 수정을 진행한 뒤에 위 명령어로 설치진행 해주시길 바랍니다.
  - 정상 설치가 완료되면 Block Storage와 Shared Filesystem을 사용할 수 있습니다.
- 트러블슈팅:
  - 해당 명령어는 `hcsctl` 바이너리와 inventory directory가 존재하는 path에서 실행되어야 합니다. 에러 발생시에는 yaml 파일 수정후에, 작업중인 working directory를 먼저 확인 해주세요. 
  - `panic: NOT FOUND 'CephCluster'` 에러가 발생했을 때는 yaml 파일 내 image registry 와 image version 정보들이 모두 치환되었는지 확인 필요합니다. 

## Step 4. rook 설치 확인

- 목적 : `rook 설치 확인`
- 순서 : 
  - kubectl get pods -n rook-ceph
  ``` shell
  NAME                                                  READY   STATUS      RESTARTS   AGE
  csi-cephfsplugin-4fdds                                3/3     Running     0          4d22h
  csi-cephfsplugin-provisioner-74964d6869-h8g9q         5/5     Running     0          4d22h
  csi-cephfsplugin-provisioner-74964d6869-vpwh5         5/5     Running     0          4d22h
  csi-rbdplugin-ph28f                                   3/3     Running     0          4d22h
  csi-rbdplugin-provisioner-79cb7f7cb4-9p8vd            6/6     Running     0          4d22h
  csi-rbdplugin-provisioner-79cb7f7cb4-fdh8m            6/6     Running     0          4d22h
  rook-ceph-crashcollector-hyeongbin-759985c655-pp4f5   1/1     Running     0          4d22h
  rook-ceph-mgr-a-797d9b578-6smnx                       1/1     Running     0          4d22h
  rook-ceph-mon-a-55f4754f4f-6tsrs                      1/1     Running     0          4d22h
  rook-ceph-operator-657fb97bf9-9lwdg                   1/1     Running     0          4d22h
  rook-ceph-osd-0-8dcfdbf5b-z5rw4                       1/1     Running     0          4d22h
  rook-ceph-osd-prepare-hyeongbin-sqkgq                 0/1     Completed   0          4d22h
  rook-discover-hjxzj                                   1/1     Running     0          4d22h
  ```
  - ./hcsctl.test
	- 정상 사용 가능 여부 확인을 위해, 여러 시나리오 테스트를 수행할 수 있습니다.
	- 약 15분 가량 소요될 수 있습니다.
	- 해당 테스트 중 cdi test는 폐쇄망 환경에서 사용하실 수 없습니다.
- 비고 :
  - 아래 pod 들이 모두 배포되고, status 가 running 인지 확인합니다.
	- csi-cephfsplugin
	- csi-cephfsplugin-provisioner
	- csi-rbdplugin
	- csi-rbdplugin-provisioner
	- rook-ceph-crashcollector
	- rook-ceph-mgr
	- rook-ceph-mon
	- rook-ceph-operator
	- rook-ceph-osd
	- rook-ceph-osd-prepare
	- rook-discover
  - cluster.yaml 파일 설정에 따라서 배포된 pod 의 개수는 다를 수 있습니다.

## Step 5. rook 제거

- 목적 : `rook 제거`
- 순서 : 
  - ./hcsctl uninstall {$inventory_name}
	- hcsctl 로 설치시 사용한 inventory 이름을 명시하여 hypercloud-storage 를 제거합니다.
  - 제거 완료 후 출력되는 메시지를 확인하여 디바이스 초기화를 위해 다음 작업들을 수행해야 될 수 있습니다.
	- sudo rm -rf /var/lib/rook
	  - k8s Cluster의 모든 노드에서 /var/lib/rook directory를 삭제합니다.
	- 모든 osd의 backend directory 혹은 device를 삭제합니다.
	  - osd의 backend가 directory인 경우 (backend directory 경로 예시: /mnt/cephdir)
	    - sudo rm -rf /mnt/cephdir
	  - osd의 backend가 device인 경우 (backend device 예시: sdb)
		- device의 파티션 정보 제거
		  - sudo sgdisk --zap-all /dev/sdb
		- device mapper에 남아있는 ceph-volume 정보 제거 (각 노드당 한 번씩만 수행하면 됨)
		  - sudo ls /dev/mapper/ceph-* | sudo xargs -I% -- dmsetup remove %
		- /dev에 남아있는 찌꺼기 파일 제거
		  - sudo rm -rf /dev/ceph-*
- 비고 :
  - 재설치시에도 디바이스 초기화를 위해 위의 작업들이 반드시 수행되어야 합니다.
