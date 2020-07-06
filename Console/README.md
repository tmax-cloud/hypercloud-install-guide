
# Console 설치 가이드

## 구성 요소 및 버전
* 구성 요소1([tmaxcloud/tmax/cafe:v2](https://hub.docker.com/cafe/tags))
* 구성 요소2([tmaxcloud/tmax/gym:v2](https://hub.docker.com/gym/tags))
* 구성 요소3

## Prerequisites
1. 구성 요소를 설치하기 전에 필요한 조건을 기술합니다.
    * 조건에 대한 상세 설명을 기술합니다.
2. Console 설치 전 HyperCloud4 Operator, Grafana, Istio(Kiali, Jaeger), Prometheus가 설치되어 있어야 합니다.

## 폐쇄망 설치 가이드
폐쇄망에서 설치를 진행해야 하는 경우 필요한 추가 작업에 대해 기술합니다.
1. 첫번째 폐쇄망 설치 작업
    * 작업에 대한 상세 설명 1
    * 작업에 대한 상세 설명 2

2. 두번째 폐쇄망 설치 작업
    * 작업에 대한 상세 설명 

## Install Steps
0. [스텝 0](https://스텝_0로_바로_가기_위한_링크)
1. [스텝 1](https://스텝_1로_바로_가기_위한_링크)
2. [스텝 2](https://스텝_2로_바로_가기_위한_링크)

## Step 0. 스텝 0
* 목적 : `해당 step의 간단한 설명을 기술합니다.`
* 생성 순서 : 
    * step을 진행하기 위한 과정에 대해 기술합니다.
	    * 상세 설명
		    * 상세 설명
* 비고 :
    * 생성 순서에 기술한 내용 외에 추가 정보를 기술합니다.
	    * 상세 설명
		    * 상세 설명

## Step 1. console 설치에 필요한 Infra 세팅
* 목적 : console을 위한 Namespace, ResourceQuota, ServiceAccount, ClusterRole, ClusterRoleBinding 생성
* 생성 순서 : 
    * 작업 폴더에 [1.initialization.yaml](https://raw.githubusercontent.com/tmax-cloud/hypercloud-console/hc-dev/install-yaml/1.initialization.yaml) 파일을 생성하고, @@NAME_NS@@를 모두 원하는 문자열로 교체합니다.
	    * 이 과정에서 @@NAME_NS@@ 대신 기입하는 문자열은 console이 설치될 Namespace의 이름이 됩니다.
    * `kubectl create -f 1.initialization.yaml` 을 실행합니다.

## Step 2. crt, key, Secret 생성
* 목적 : console으로의 https 접속을 지원하기 위함
* 생성 순서 : 
    * 작업 폴더 하위의 tls 폴더에 crt, key 파일을 준비합니다.
	    * 발급받은 인증서가 있는 경우
		    * 발급받은 인증서에 암호가 없는 경우
		    * 발급받은 인증서에 암호가 있는 경우
	    * 발급받은 인증서가 없는 경우
		    * 작업 폴더 하위에 tls 폴더를 생성하여 진입한 후, 다음 명령어를 한 줄씩 실행합니다.
			    * `openssl genrsa -out tls.key 2048`
			    * `openssl req -new -key tls.key -out tls.csr`
			    * `openssl x509 -req -days 3650 -in tls.csr -signkey tls.key -out tls.crt`
    * b 작업을 수행합니다.
	* c 작업을 수행합니다.
* 비고 :
    * a의 1번을 수정하면 b 기능을 수행할 수 있습니다.
	    * b의 종류는 다음과 같습니다.
		    * ...

