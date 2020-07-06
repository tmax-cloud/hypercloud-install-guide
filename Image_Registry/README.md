# Image Registry 설치 가이드

## 구성 요소 및 버전
* docker

## Prerequisites
## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 shell script와 tar파일을 준비한다.
1. **폐쇄망에서 설치하는 경우** run-registry.sh, docker-registry.tar를 Master 환경에 다운로드한다. 
    * 작업 디렉토리 생성 및 환경 설정
    ```bash
    $ mkdir -p ~/registry-install
    $ export REGISTRY_HOME=~/registry-install
    $ cd $REGISTRY_HOME
    ```
## Install Steps
0. [docker 설치](https://스텝_0로_바로_가기_위한_링크)
0. [registry 실행](https://스텝_0로_바로_가기_위한_링크)

## Step 0. docker 설치
* 목적 : 'docker registry를 구축하기 위해 docker를 설치한다'
* 생성 순서 : 
    * run-registry.sh를 실행한다.
    	 * run-registry.sh, docker-registry.tar 파일이 같은 $REGISTRY_HOME 디렉토리에 있어야 한다.
    ```bash
    $ sudo ./run-registry.sh $PWD {IP}:5000
    ```
    * 확인
    ```bash
    $ curl {IP}:5000/v2/_catalog
![image](figure/)

## Step 1. registry 실행
* 목적 : '폐쇄망 환경에서 docker hub에 접속할 수 없을 때, docker registry를 이용해 image 사용을 위한 registry를 구축한다.'
* 생성 순서 : 
    * run-registry.sh를 실행한다.
    	 * run-registry.sh, docker-registry.tar 파일이 같은 $REGISTRY_HOME 디렉토리에 있어야 한다.
    ```bash
    $ sudo ./run-registry.sh $PWD {IP}:5000
    ```
    * 확인
    ```bash
    $ curl {IP}:5000/v2/_catalog
![image](figure/)
