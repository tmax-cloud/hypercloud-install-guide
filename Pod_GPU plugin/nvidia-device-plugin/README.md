
# NVIDIA GPU Device Plugin 설치 가이드

## 구성 요소 및 버전
* nvidia gpu device plugin([docker.io/nvidia/k8s-device-plugin:1.0.0-beta4](https://hub.docker.com/layers/nvidia/k8s-device-plugin/1.0.0-beta4/images/sha256-76c08ab2780e88142384c6d9da48dae1788555273a5429a3eb67ed68a9bc358a?context=explore))

## Prerequisites
설치를 진행하기 전 아래의 과정을 통해 필요한 tar 파일을 준비한다.
1. 환경에 맞는 installer tar를 모든 노드에 다운로드한다.
    * 작업 디렉토리 생성 및 환경 설정
        ```bash
        $ mkdir -p ~/nvidia-dev-plugin-install
        $ cd ~/nvidia-dev-plugin-install

        $ export OS_RELEASE=prolinux_7.6
        $ export GPU_INSTALLER_VERSION=2.1
        $ export INSTALLER_HOME=~/nvidia-dev-plugin-install/k8s-gpu-installer-${OS_RELEASE}-v${GPU_INSTALLER_VERSION}
        ```
    * 필요한 tar파일 다운로드 및 아카이브 해제
        ```bash
        $ wget -O nvidia-installer.tar https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/master/Pod_GPU%20plugin/nvidia-device-plugin/k8s-gpu-installer-${OS_RELEASE}-v${GPU_INSTALLER_VERSION}.tar
        $ tar -xzvf nvidia-installer.tar
        ```

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 파일을 준비한다.
1. **폐쇄망에서 설치하는 경우** 사용하는 image repository에 NVIDIA Device Plugin 설치 시 필요한 이미지를 push한다.
    ```bash
    $ export NVIDIA_PLUGIN_VERSION=1.0.0-beta4
    $ docker pull nvidia/k8s-device-plugin:${NVIDIA_PLUGIN_VERSION}
    $ docker save nvidia/k8s-device-plugin:${NVIDIA_PLUGIN_VERSION} > k8s-device-plugin_${NVIDIA_PLUGIN_VERSION}.tar
    ```

2. 위의 과정에서 생성한 tar 파일들을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 이미지를 push한다.
    ```bash
    $ docker load < k8s-device-plugin_${NVIDIA_PLUGIN_VERSION}.tar

    # export REGISTRY={registry name}
    $ docker tag nvidia/k8s-device-plugin:${NVIDIA_PLUGIN_VERSION} ${REGISTRY}/k8s-device-plugin:${NVIDIA_PLUGIN_VERSION}

    $ docker push ${REGISTRY}/k8s-device-plugin:${NVIDIA_PLUGIN_VERSION}
    ```

## Install Steps - for GPU node
0. [NVIDIA driver 설치](#step-0-nvidia-driver-설치)
1. [nvidia-docker2 설치](#step-1-nvidia-docker2-설치)

## Step 0. NVIDIA driver 설치
* 목적 : `GPU device에 적절한 nvidia driver를 설치`
* 생성 순서 : 
    * nouveau 비활성화
        ```bash
        $ vi /etc/modprobe.d/blacklist-nvidia-nouveau.conf
        # write the following to the file:
        blacklist nouveau
        options nouveau modeset=0
        ```
    * 재부팅
        ```bash
        $ reboot
        ```
    * 필요한 패키지 설치
        ```bash
        $ KERNEL_RELEASE=`uname -r | sed "s/.\`uname -m\`//g"`
        $ yum -y install kernel-devel-${KERNEL_RELEASE} kernel-headers-${KERNEL_RELEASE} gcc make dkms jq
        ```
    * [nvidia 홈페이지](https://www.nvidia.co.kr/Download/index.aspx)에서 GPU device에 적절한 nvidia driver를 다운받아 설치
        ```bash
        $ chmod +x ./your-nvidia-file.run
        $ ./your-nvidia-file.run --dkms -s
        ```
    * nvidia driver가 설치되었는지 확인
        ```bash
        $ nvidia-smi
        ```

## Step 1. nvidia-docker2 설치
* 목적 : `nvidia-docker2를 설치`
* 생성 순서 : 
    * nvidia-docker2를 설치
        ```bash
        $ cd ${INSTALLER_HOME}
        $ ./gpunode-install-nvidia-docker2.sh
        ```

## Install Steps - for master node
0. [GPU node에 label 추가](#step-0-gpu-node에-label-추가)
1. [NVIDIA device plugin을 배포](#step-1-nvidia-device-plugin을-배포)

## Step 0. GPU node에 label 추가
* 목적 : `Device plugin을 GPU node에만 deploy하기 위해 GPU node에 label을 추가`
* 생성 순서 : 
    * 'tmax/gpudriver=nvidia' label을 GPU node에 추가
        ```bash
        $ kubectl label nodes {GPU node name} tmax/gpudriver=nvidia
        ```
## Step 1. NVIDIA device plugin을 배포
* 목적 : `NVIDIA device plugin을 배포`
* 생성 순서 : 
    * nvidia device plugin daemonset을 배포
        ```bash
        $ cd ${INSTALLER_HOME}
        $ ./masternode-add-device-plugin.sh
        ```
    * nvidia device plugin이 배포되었는지 확인
        ```bash
        # to verify nvidia-device-plugin pods are running
        $ kubectl get pods -n kube-system | grep nvidia-device-plugin-daemonset
        # to check the number of gpu devices on each nodes
        $ kubectl get nodes "-o=custom-columns=NAME:.metadata.name,GPU:.status.allocatable.nvidia\.com/gpu"
        ```
* 비고 :
    * `폐쇄망에서 설치를 진행하여 별도의 image registry를 사용하는 경우 registry 정보를 추가로 설정해준다.`
        ```bash
        $ cd cd ${INSTALLER_HOME}
        $ sed -i 's/nvidia\/k8s-device-plugin/'${REGISTRY}'\/k8s-device-plugin/g' nvidia-device-plugin-daemonset.yml
        ```