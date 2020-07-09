
# kubevirt GPU device plugin pass-through 설치 가이드

## 구성 요소 및 버전
* nvcr.io/nvidia/kubevirt-gpu-device-plugin:v1.0.0

## Prerequisites
* vfi-pci driver 설정 (CentOS7)
   1. nvidia driver 삭제
   VM이 사용할 GPU가 존재하는 node들에 nvidia driver가 설치되어 있다면 삭제합니다.
   ```bash
   $ nvidia-uninstall
   ```
   2. IOMMU 설정
   VM이 사용할 GPU가 존재하는 node들에 IOMMU 기능을 enable합니다.
   intel_iommu=on modprobe.blacklist=nouveau를 GRUB_CMDLINE_LINUX 끝에 설정합니다.
   ```bash
   $ vi /etc/default/grub
   # line 6: add (if AMD CPU, add [amd_iommu=on])
   GRUB_TIMEOUT=5
   GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
   GRUB_DEFAULT=saved
   GRUB_DISABLE_SUBMENU=true
   GRUB_TERMINAL_OUTPUT="console"
   GRUB_CMDLINE_LINUX="rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet intel_iommu=on modprobe.blacklist=nouveau"
   GRUB_DISABLE_RECOVERY="true"
   ```
   grub config을 재설정후 재부팅을 합니다.
   ```bash
   $ grub2-mkconfig -o /boot/grub2/grub.cfg
   ```
   UEFI system을 사용하는 경우 아래의 명령어를 통해 grub config를 재설정합니다.
   ```bash
   $ grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
   ```
   UE
   재부팅 후, IOMMU가 enable되었는지 확인합니다.
   ```bash
   $ dmesg | grep -E "DMAR|IOMMU"
   ```
   nouveau가 disable되었는지 확인합니다.
   ```bash
   $ dmesg | grep -i nouveau
   ```
   3. vfio-pci kernel module 로드
   노드에 설치되어 있는 GPU의 vendor-ID와 device-ID를 찾습니다.
   아래의 예시에서 vendor-ID:device-ID는 10de:1b38 입니다.
   (lspci 명령어는 yum install pciutils 를 통해 설치할 수 있습니다)
   ```bash
   $ lspci -nn | grep -i nvidia
   04:00.0 3D controller [0302]: NVIDIA Corporation GP102GL [Tesla P40] [10de:1b38] (rev a1)
   ```
   위에서 얻은 vendor-ID와 device-ID를 이용하여 해당 pci device의 driver를 vfio-pci로 설정합니다.
   만약 VGA compatible controller 외의 다른 device가 있다면 해당 device의 driver도 vfio-pci로 설정합니다.
   ```bash
   echo "options vfio-pci ids=vendor-ID:device-ID" > /etc/modprobe.d/vfio.conf
   ex) echo "options vfio-pci ids=10de:1b38" > /etc/modprobe.d/vfio.conf
   ```
   vfio-pci module을 load하기 위해 config를 생성후 재부팅합니다.
   ```bash
   echo 'vfio-pci' > /etc/modules-load.d/vfio-pci.conf
   reboot
   ```
   재부팅 후, vfio-pci driver가 해당 GPU에 대해 정상적으로 로드되었는지 확인합니다.
   ```bash
   $ lspci -nnk -d 10de:
   04:00.0 3D controller [0302]: NVIDIA Corporation GP102GL [Tesla P40] [10de:1b38] (rev a1)
        Subsystem: NVIDIA Corporation Device [10de:11d9]
        Kernel driver in use: vfio-pci
        Kernel modules: nouveau
   ```
* 폐쇄망일때 이미지 관리
   1. public network 환경에서 이미지를 받아 tar 형태로 저장합니다.
   ```bash
   $ docker pull nvcr.io/nvidia/kubevirt-gpu-device-plugin:v1.0.0
   $ docker save -o kubevirt-gpu-device-plugin.tar nvcr.io/nvidia/kubevirt-gpu-device-plugin:v1.0.0
   ```
   2. tar 이미지를 private registry에 push합니다.
   ```bash
   $ docker load -i kubevirt-gpu-device-plugin.tar
   # docker tag nvcr.io/nvidia/kubevirt-gpu-device-plugin:v1.0.0 {private_registry_endpoint}/nvidia/kubevirt-gpu-device-plugin:v1.0.0
   # ex) docker tag nvcr.io/nvidia/kubevirt-gpu-device-plugin:v1.0.0 10.0.0.1:5000/nvidia/kubevirt-gpu-device-plugin:v1.0.0
   $ docker push 10.0.0.1:5000/nvidia/kubevirt-gpu-device-plugin:v1.0.0
   ```
   
## Install Steps - for master node
0. [GPU node에 label 추가](#step-0-gpu-node에-label-추가)
1. [NVIDIA device plugin을 배포](#step-1-kubevirt-gpu-device-plugin-배포)

## Step 0. GPU node에 label 추가
* 목적 : `Device plugin을 VM이 사용할 GPU node에만 deploy하기 위해 GPU node에 label을 추가`
* 생성 순서 : 
    * 'tmax/gpudriver=vfio' label을 GPU node에 추가
        ```bash
        $ kubectl label nodes {GPU node name} tmax/gpudriver=vfio
        ```
## Step 1. kubevirt gpu device plugin 배포
* 목적 : `kubevirt gpu device plugin 배포`
* 생성 순서 : 
    * kubevirt configmap 생성
        ```bash
        $ wget https://raw.githubusercontent.com/NVIDIA/kubevirt-gpu-device-plugin/master/examples/kubevirt-featuregate-cm.yaml
        $ kubectl create -f kubevirt-featuregate-cm.yaml
        ```
        만약 이미 kubevirt-config로 configmap이 생성되어 있다면 아래의 명령어를 통해 configmap의 data.feature-gates에 GPU를 추가합니다.
        ```bash
        $ kubectl edit configmap -n kubevirt kubevirt
        data:
          feature-gates: "...,GPU"
        ```
    * nvidia device plugin daemonset 배포
        ```bash
        $ wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/master/VM_KubeVirt/GPU%20plugin/nvidia-kubevirt-gpu-device-plugin.yaml
        $ kubectl create -f nvidia-kubevirt-gpu-device-plugin.yaml
        ```
    * nvidia device plugin이 배포되었는지 확인
        ```bash
        # to verify nvidia-device-plugin pods are running
        $ kubectl get pods -n kube-system | grep nvidia-kubevirt-gpu-dp
        ```
* 비고 :
    * `폐쇄망에서 설치를 진행하여 별도의 image registry를 사용하는 경우 registry 정보를 추가로 설정해준다.`
        ```bash
        # $REGISTRY 환경변수의 값을 private registry endpoint로 설정합니다.
        # ex) export REGISTRY=10.0.0.1:5000
        $ sed -i 's/nvcr.io/'${REGISTRY}'\/g' nvidia-kubevirt-gpu-device-plugin.yaml
        ```
