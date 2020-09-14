# HyperCloud Webhook 설치 가이드

## 구성 요소 및 버전
* hypercloud-webhook 
    * ([tmaxcloudck/hypercloud-webhook:b4.1.0.20](https://hub.docker.com/layers/tmaxcloudck/hypercloud-webhook/b4.1.0.20/images/sha256-c0b89b02335bfde9024ce7388c36b229dd4ab224f90fef872e13f973bb29a48f?context=explore)) 

## Prerequisites
1. 해당 모듈 설치 전 HyperCloud Operator 모듈 설치 필요
    * ([HyperCloud Operator](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/HyperCloud%20Operator/README.md))

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. **폐쇄망에서 설치하는 경우** 사용하는 image repository에 HyperCloud Webhook 설치 시 필요한 이미지를 push한다. 

    * 작업 디렉토리 생성 및 환경 설정
    ```bash
    $ mkdir -p ~/hypercloud-webhook-install
    $ export WEBHOOK_HOME=~/hypercloud-webhook-install
    $ export WEBHOOK_VERSION=b4.1.0.20
    $ cd $WEBHOOK_HOME
    ```
    * 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받는다.
    ```bash
    $ sudo docker pull tmaxcloudck/hypercloud-webhook:${WEBHOOK_VERSION}
    $ sudo docker save tmaxcloudck/hypercloud-webhook:${WEBHOOK_VERSION} > hypercloud-webhook_${WEBHOOK_VERSION}.tar
    ```
    * install yaml을 다운로드한다.
    ```bash
    $ git clone https://github.com/tmax-cloud/hypercloud-install-guide.git
    $ cd hypercloud-install-guide/HyperCloud Webhook/manifests
    ```
  
2. 위의 과정에서 생성한 tar 파일들을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 이미지를 push한다.
    ```bash
    $ sudo docker load < hypercloud-webhook_${WEBHOOK_VERSION}.tar
    
    $ sudo docker tag tmaxcloudck/hypercloud-webhook:${WEBHOOK_VERSION} ${REGISTRY}/hypercloud-webhook:${WEBHOOK_VERSION}
    
    $ sudo docker push ${REGISTRY}/hypercloud-webhook:${WEBHOOK_VERSION}
    ```    

## Install Steps
0. [hypercloud-webhook yaml 수정](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/HyperCloud%20Webhook#step-0-hypercloud-webhook-yaml-%EC%88%98%EC%A0%95)
1. [Secret 생성](https://github.com/tmax-cloud/hypercloud-install-guide/tree/chosangwon93-patch-1/HyperCloud%20Webhook#step-1-secret-%EC%83%9D%EC%84%B1)
2. [HyperCloud Webhook Server 설치](https://github.com/tmax-cloud/hypercloud-install-guide/tree/chosangwon93-patch-1/HyperCloud%20Webhook#step-2-hypercloud-webhook-server-%EC%84%A4%EC%B9%98)
3. [HyperCloud Webhook Config 생성](https://github.com/tmax-cloud/hypercloud-install-guide/tree/chosangwon93-patch-1/HyperCloud%20Webhook#step-3-hypercloud-webhook-config-%EC%83%9D%EC%84%B1)
4. [HyperCloud Webhook Config 적용](https://github.com/tmax-cloud/hypercloud-install-guide/tree/chosangwon93-patch-1/HyperCloud%20Webhook#step-4-hypercloud-webhook-config-%EC%A0%81%EC%9A%A9)
5. [HyperCloud Audit Webhook Config 생성](https://github.com/tmax-cloud/hypercloud-install-guide/tree/chosangwon93-patch-1/HyperCloud%20Webhook#step-5-hypercloud-audit-webhook-config-%EC%83%9D%EC%84%B1)
6. [HyperCloud Audit Webhook Config 적용](https://github.com/tmax-cloud/hypercloud-install-guide/tree/chosangwon93-patch-1/HyperCloud%20Webhook#step-6-hypercloud-audit-webhook-config-%EC%A0%81%EC%9A%A9)
7. [test-yaml 배포](https://github.com/tmax-cloud/hypercloud-install-guide/tree/chosangwon93-patch-1/HyperCloud%20Webhook#step-7-test-yaml-%EB%B0%B0%ED%8F%AC)

## Step 0. hypercloud-webhook yaml 수정
* 목적 : `hypercloud-webhook yaml에 이미지 registry, 버전 및 마스터 노드 정보를 수정` ([manifests](manifests) 디렉토리 참고)
* 생성 순서 : 아래의 command를 실행하여 사용하고자 하는 image 버전을 수정한다. ([02_webhook-deployment.yaml](manifests/02_webhook-deployment.yaml))
    ```bash
    $ sed -i 's/{webhook_version}/'${WEBHOOK_VERSION}'/g' 02_webhook-deployment.yaml
    $ sed -i 's/{hostname}/'${HOSTNAME}'/g' 02_webhook-deployment.yaml
    ```
* 비고 :
    * 폐쇄망에서 설치를 진행하여 별도의 image registry를 사용하는 경우 registry 정보를 추가로 설정해준다.
	```bash
	$ sed -i 's/tmaxcloudck\/hypercloud-webhook/'${REGISTRY}'\/hypercloud-webhook/g' 02_webhook-deployment.yaml
	```

## Step 1. Secret 생성
* 목적 : `Step 1을 통해 생성한 인증서를 Secret으로 변환합니다`
* 생성 순서 : [01_create_secret.sh](manifests/01_create_secret.sh) 실행 `ex) sh 01_create_secret.sh`

## Step 2. HyperCloud Webhook Server 설치
* 목적 : `HyperCloud Webhook Server 설치`
* 생성 순서 : [02_webhook-deployment.yaml](manifests/02_webhook-deployment.yaml) 실행 `ex) kubectl apply -f 02_webhook-deployment.yaml`

## Step 3. HyperCloud Webhook Config 생성
* 목적 : `앞서 생성한 인증서 정보를 기반으로 Webhook 연동 설정 파일 생성`
* 생성 순서 : 아래의 command를 실행하여 Webhook Config를 생성한다. ([03_gen-webhook-config.sh](manifests/03_gen-webhook-config.sh))
    ```bash
    $ sh 03_gen-webhook-config.sh
    ```
	
## Step 4. HyperCloud Webhook Config 적용
* 목적 : `Webhook 연동 설정을 적용하여 API 서버가 Webhook Server와 HTTPS 통신을 하도록 설정`
* 생성 순서 : [04_webhook-configuration.yaml](manifests/04_webhook-configuration.yaml.template) 실행 `ex) kubectl apply -f 04_webhook-configuration.yaml`

## Step 5. HyperCloud Audit Webhook Config 생성
* 목적 : `앞서 생성한 인증서 정보를 기반으로 Audit Webhook 연동 설정 파일 생성`
* 생성 순서 : 아래의 command를 실행하여 Webhook Config를 생성한다. ([05_gen-audit-config.sh](manifests/05_gen-audit-config.sh))
    ```bash
    $ sh 05_gen-audit-config.sh
	$ cp 06_audit-webhook-config /etc/kubernetes/pki/audit-webhook-config
	$ cp 07_audit-policy.yaml /etc/kubernetes/pki/audit-policy.yaml
    ```

## Step 6. HyperCloud Audit Webhook Config 적용
* 목적 : `Audit Webhook 연동 설정을 적용하여 API 서버가 Audit Webhook Server와 HTTPS 통신을 하도록 설정`
* 생성 순서 : /etc/kubernetes/manifests/kube-apiserver.yaml을 아래와 같이 수정한다.
	```
	spec.containers.command:
	- --audit-log-path=/var/log/kubernetes/apiserver/audit.log
	- --audit-policy-file=/etc/kubernetes/pki/policy.yaml
	- --audit-webhook-config-file=/etc/kubernetes/pki/audit-webhook-config
	spec.dnsPolicy: ClusterFirstWithHostNet

	```

## Step 7. test-yaml 배포
* 목적 : `Webhook Server 동작 검증`
* 생성 순서 : [namespaceclaim.yaml](manifests/test-yaml/namespaceclaim.yaml) 실행 `ex) kubectl apply -f namespaceclaim.yaml`
	```
	kubectl describe namespaceclaim example-namespace-webhook
	Annotation에 creator/updater/createdTime/updatedTime 필드가 생성 되었는지 확인

	```
