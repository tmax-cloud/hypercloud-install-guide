# secret-watcher 설치 가이드

## 구성 요소
* secret-watcher 
	* image: [https://hub.docker.com/r/tmaxcloudck/hypercloud4-secret-watcher/tags](https://hub.docker.com/r/tmaxcloudck/hypercloud4-secret-watcher/tags)
	* git: [https://github.com/tmax-cloud/secret-watcher](https://github.com/tmax-cloud/secret-watcher)

## Prerequisite
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. **폐쇄망에서 설치하는 경우** 사용하는 image repository에 필요한 이미지를 push한다. 

    * 작업 디렉토리 생성 및 환경 설정
    ```bash
	$ mkdir -p ~/secret-watcher-install
	$ export HPCD_SW_HOME=~/secret-watcher-install
	$ export HPCD_SW_VERSION=<tag1>
	$ cd ${HPCD_SW_HOME}

	* <tag1>에는 설치할 hypercloud4-secret-watcher 버전 명시
		예시: $ export HPCD_SW_VERSION=4.1.0.9
    ```
    * 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받는다.
    ```bash
	# secret-watcher
	$ sudo docker pull tmaxcloudck/hypercloud4-secret-watcher:b${HPCD_SW_VERSION}
	$ sudo docker save tmaxcloudck/hypercloud4-secret-watcher:b${HPCD_SW_VERSION} > hypercloud4-secret-watcher_b${HPCD_SW_VERSION}.tar
    ```
    * install yaml을 다운로드한다.
    ```bash
    $ wget -O secret-watcher.tar.gz https://github.com/tmax-cloud/secret-watcher/archive/v${HPCD_SW_VERSION}.tar.gz
    ```
  
2. 위의 과정에서 생성한 tar 파일들을 `폐쇄망 환경으로 이동`시킨 뒤 사용하려는 registry에 이미지를 push한다.
	* 작업 디렉토리 생성 및 환경 설정
    ```bash
	$ mkdir -p ~/secret-watcher-install
	$ export HPCD_SW_HOME=~/secret-watcher-install
	$ export HPCD_SW_VERSION=<tag1>
	$ export REGISTRY=<REGISTRY_IP_PORT>
	$ cd ${HPCD_SW_HOME}

	* <tag1>에는 설치할 hypercloud4-secret-watcher 버전 명시
		예시: $ export HPCD_SW_VERSION=4.1.0.9
	* <REGISTRY_IP_PORT>에는 폐쇄망 Docker Registry IP:PORT명시
		예시: $ export REGISTRY=192.168.6.110:5000
	```
    * 이미지 load 및 push
    ```bash
    # Load Images
	$ sudo docker load < hypercloud4-secret-watcher_b${HPCD_SW_VERSION}.tar
    
    # Change Image's Tag For Private Registry
	$ sudo docker tag tmaxcloudck/hypercloud4-secret-watcher:b${HPCD_SW_VERSION} ${REGISTRY}/tmaxcloudck/hypercloud4-secret-watcher:b${HPCD_SW_VERSION}
    
    # Push Images
	$ sudo docker push ${REGISTRY}/tmaxcloudck/hypercloud4-secret-watcher:b${HPCD_SW_VERSION}
    ```

## Install Steps
0. [hypercloud-secret-watcher-daemonset.yaml 수정](https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/SecretWatcher/README.md#step-0-hypercloud-secret-watcher-daemonsetyaml-%EC%88%98%EC%A0%95)
1. [hypercloud-secret-watcher-daemonset.yaml 실행](https://github.com/tmax-cloud/hypercloud-install-guide/tree/4.1/SecretWatcher#step-1-hypercloud-secret-watcher-daemonsetyaml-%EC%8B%A4%ED%96%89)

## Step 0. hypercloud-secret-watcher-daemonset.yaml 수정
* 목적 : `hypercloud-secret-watcher-daemonset.yaml 수정`
* 준비:
	* yaml 파일 다운로드
	```bash
	$ mkdir -p ~/secret-watcher-install
	$ export HPCD_SW_HOME=~/secret-watcher-install
	$ export HPCD_SW_VERSION=<tag1>
	$ cd ${HPCD_SW_HOME}
	
	* <tag1>에는 설치할 hypercloud4-secret-watcher 버전 명시
		예시: $ export HPCD_SW_VERSION=4.1.0.9
	$ wget https://raw.githubusercontent.com/tmax-cloud/secret-watcher/v${HPCD_SW_VERSION}/k8s-install/hypercloud-secret-watcher-daemonset.yaml
	```
	*  image version 수정
		```bash
		$ sed -i 's/tmaxcloudck\/hypercloud4-secret-watcher:latest/tmaxcloudck\/hypercloud4-secret-watcher:'${HPCD_SW_VERSION}'/g' ${HPCD_SW_HOME}/secret-watcher-${HPCD_SW_VERSION}/k8s-install/hypercloud-secret-watcher-daemonset.yaml
		```
* 비고
	* 폐쇄망의 경우 
		```bash
		$ cd ${HPCD_SW_HOME}
		$ tar -xvzf secret-watcher.tar.gz
		
		# 1) spec.template.spec.containers.image: tmaxcloudck/hypercloud4-secret-watcher:latest 값을 
		# 		<REGISTRY>/tmaxcloudck/hypercloud4-secret-watcher:<tag> 으로 수정
		#	Example:
		#		spec.template.spec.containers.image: 192.168.6.110:5000/tmaxcloudck/hypercloud4-secret-watcher:b4.1.0.9
		#
		#	<REGISTRY>: 폐쇄망 registry의 IP:PORT 
		#	<tag>: load한 이미지의 tag 
		
## Step 1. hypercloud-secret-watcher-daemonset.yaml 실행
* 목적 : `secret-watcher daemonset 생성`
* 실행: 
	```bash
	$ kubectl apply -f ${HPCD_SW_HOME}/secret-watcher-${HPCD_SW_VERSION}/k8s-install/hypercloud-secret-watcher-daemonset.yaml
	```

