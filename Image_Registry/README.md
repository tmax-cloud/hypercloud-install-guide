# Image Registry 설치 가이드

## 구성 요소 및 버전
* docker-ce(v18.09.7)

## Prerequisites
## 폐쇄망 설치 가이드

  * 작업 디렉토리 생성 및 환경 설정
    ```bash
    $ mkdir -p ~/registry-install
    $ cd ~/registry-install
    ```
    * run-registry.sh, docker-registry.tar를 Master 환경에 다운로드한다.
        * https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Image_Registry/installer
        * git이 설치되어 있는 경우 clone
           * git clone https://github.com/tmax-cloud/hypercloud-install-guide.git
           * cd ~/registry-install/hypercloud-install-guide/Image_Registry/installer

## Install Steps
0. [docker 설치](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Image_Registry/README.md#step-0-docker-%EC%84%A4%EC%B9%98)
1. [registry 실행](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Image_Registry/README.md#step-1-registry-%EC%8B%A4%ED%96%89)

## Step 0. docker 설치
* 목적 : `docker registry를 구축하기 위해 docker를 설치한다.`
* 생성 순서 : 
    * docker를 설치한다.
    ```bash
    $ sudo yum install -y docker-ce
    ```
    * docker damon에 insecure-registries를 등록한다.
      * sudo vi /etc/docker/daemon.json
    ```bash
    {
        "insecure-registries": ["{IP}:5000"]
    }
    ```
    ![image](figure/docker_registry.PNG)
    * docker를 재실행하고 status를 확인한다.
    ```bash
    $  sudo systemctl enable docker 
    $  sudo systemctl restart docker
    $  sudo systemctl status docker
    ```    
    
## Step 1. registry 실행
* 목적 : `폐쇄망 환경에서 docker hub에 접속할 수 없을 때, docker registry를 이용해 image 사용을 위한 registry를 구축한다.`
* 생성 순서 : 
    * run-registry.sh를 실행한다.
    	 * run-registry.sh, docker-registry.tar 파일이 같은 $REGISTRY_HOME 디렉토리에 있어야 한다.
    ```bash
    $ sudo ./run-registry.sh ~/registry-install {IP}:5000
    ```
    ![image](figure/registry.PNG)

    * 확인
    ```bash
    $ curl {IP}:5000/v2/_catalog
    ```
    ![image](figure/catalog.PNG)
