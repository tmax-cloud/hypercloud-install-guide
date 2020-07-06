# Image Registry 설치 가이드

## 구성 요소 및 버전
* docker
* 구성 요소2([tmaxcloud/tmax/gym:v2](https://hub.docker.com/gym/tags))

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
2. 위의 과정에서 다운받은 파일들을 폐쇄망 환경으로 이동시킨 뒤 docker registry image를 이용하여 registry를 띄운다.
    * run-registry.sh를 실행한다.
    	    * run-registry.sh, docker-registry.tar 파일이 같은 $REGISTRY_HOME 디렉토리에 있어야 한다.
    ```bash
    $ sudo ./run-registry.sh $PWD {IP}:5000
    ```
## 폐쇄망 설치 가이드
폐쇄망에서 설치를 진행해야 하는 경우 필요한 추가 작업에 대해 기술합니다.
1. 첫번째 폐쇄망 설치 작업
    * 작업에 대한 상세 설명 1
	    * 상세 내역 1
		* 상세 내역 2
    * 작업에 대한 상세 설명 2

2. 두번째 폐쇄망 설치 작업
    * 작업에 대한 상세 설명 

## Install Steps
0. [스텝 0](https://스텝_0로_바로_가기_위한_링크)
1. [스텝 1](https://스텝_1로_바로_가기_위한_링크)
2. [스텝 2](https://스텝_2로_바로_가기_위한_링크)

## Step 0. 스텝 0
* 목적 : 폐쇄망 환경에서 docker hub에 접속할 수 없을 때, docker registry를 이용해 이미지 pull을 위한 설정
* 생성 순서 : 
    * step을 진행하기 위한 과정에 대해 기술합니다.
	    * 상세 설명
		    * 상세 설명
* 비고 :
    * 생성 순서에 기술한 내용 외에 추가 정보를 기술합니다.
	    * 상세 설명
		    * 상세 설명

## Step 1. 스탭 1
* 목적 : `스탭1을 수행하는 목적에 대해 기술합니다.`
* 생성 순서 : 스탭의 과정이 간단한 경우 하위 분류를 진행하지 않아도 됩니다.

## Step 2. 스탭 2
* 목적 : `스탭2를 수행하는 목적에 대해 기술합니다.`
* 생성 순서 : 
    * a 작업을 수행합니다.
	    * a작업을 위해 z를 수행합니다.
    * b 작업을 수행합니다.
	* c 작업을 수행합니다.
* 비고 :
    * a의 1번을 수정하면 b 기능을 수행할 수 있습니다.
	    * b의 종류는 다음과 같습니다.
		    * ...

