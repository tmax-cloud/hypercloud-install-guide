
# kubevirt 설치 가이드

## 구성 요소 및 버전
* docker.io/tmaxcloudck/alpine-container-disk-demo:v0.27.0
* docker.io/tmaxcloudck/cdi-http-import-server:v0.27.0
* docker.io/tmaxcloudck/cirros-container-disk-demo:v0.27.0
* docker.io/tmaxcloudck/cirros-custom-container-disk-demo:v0.27.0
* docker.io/tmaxcloudck/disks-images-provider:v0.27.0
* docker.io/tmaxcloudck/example-cloudinit-hook-sidecar:v0.27.0
* docker.io/tmaxcloudck/example-hook-sidecar:v0.27.0
* docker.io/tmaxcloudck/fedora-cloud-container-disk-demo:v0.27.0
* docker.io/tmaxcloudck/fedora30-cloud-container-disk-demo:v0.27.0
* docker.io/tmaxcloudck/nfs-server:v0.27.0
* docker.io/tmaxcloudck/subresource-access-test:v0.27.0
* docker.io/tmaxcloudck/virt-api:v0.27.0
* docker.io/tmaxcloudck/virt-controller:v0.27.0
* docker.io/tmaxcloudck/virt-handler:v0.27.0
* docker.io/tmaxcloudck/virt-launcher:v0.27.0
* docker.io/tmaxcloudck/virt-operator:v0.27.0
* docker.io/tmaxcloudck/virtio-container-disk:v0.27.0
* docker.io/tmaxcloudck/vm-killer:v0.27.0
* docker.io/tmaxcloudck/winrmcli:v0.27.0
* virtctl (v0.27.0)

## Prerequisites
1. 아래의 명령어를 통해 project를 다운로드하여 kubernetes의 master node에 옮깁니다.
   ```bash
   git clone https://github.com/tmax-cloud/kubevirt-installer.git
   ```
2. **폐쇄망에서 설치하는 경우** 아래 가이드를 참고 하여 image registry를 먼저 구축한다.
    * https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Image_Registry

## 폐쇄망 설치 가이드
1. 인터넷이 되는 환경에서 아래의 명령어를 수행하여 설치에 필요한 이미지들을 docker hub로부터 다운로드합니다. 
   ```bash
   $ make download
   ```
2. $REGISTRY_ENDPOINT 환경변수에 image가 저장될 private registry 주소를 입력합니다.
   ```bash
   $ export REGISTRY_ENDPOINT={registry url}
   ex) export REGISTRY_ENDPOINT=10.0.0.1:5000
   ```
3. 아래의 명령어를 수행하여 1번에서 다운로드한 image tar 파일들을 2번에서 설정한 private registry에 push합니다.
   ```bash
   $ make upload
   ```

## Install Steps
1. 아래의 명령어를 수행하여 설치를 진행합니다
   ```bash
   $ make install
   ```

## Unnstall Steps
1. 아래의 명령어를 수행하여 제거를 진행합니다.
   ```bash
   $ make uninstall
   ```
