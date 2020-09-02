# HyperAuth 설치 가이드

## 구성 요소 및 버전
* hyperauth
    * ([tmaxcloudck/hyperauth:b1.0.2.5](https://hub.docker.com/layers/tmaxcloudck/hyperauth/b1.0.2.5/images/sha256-ac5297490881a49849b1c9c58f5d2e94fe1acc4406939be9310400bc9563a6a9?context=explore)) 

## Prerequisites
X

## Dependencies
openssl

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. 사용하는 image repository에 HyperAuth 설치 시 필요한 이미지를 push한다. 


## Install Steps
1. [초기화 작업]()
2. [DB Deployment 생성]()
3. [SSL 인증서 생성]()
4. [HyperAuth Deployment 생성]()
5. [Kubernetes OIDC 연동]()

## Step 1. 초기화 작업
* 목적 : `HyperAuth 구축을 위한 초기화 작업`
* 생성 순서 : [03_webhook-deployment.yaml](manifests/03_webhook-deployment.yaml) 실행 `ex) kubectl apply -f 03_webhook-deployment.yaml`)
    ```bash
    $ mkdir ./pki
    $ sh 01_gen_certs.sh
    $ openssl pkcs12 -export -in ./pki/hypercloud4-webhook.crt -inkey ./pki/hypercloud4-webhook.key -out ./pki/hypercloud4-webhook.p12 (Export Password: webhook)
    $ keytool -importkeystore -deststorepass webhook -destkeypass webhook -destkeystore ./pki/hypercloud4-webhook.jks -srckeystore ./pki/hypercloud4-webhook.p12 -srcstoretype PKCS12 -srcstorepass webhook
    ```

## Step 2. Secret 생성
* 목적 : `Step 1을 통해 생성한 인증서를 Secret으로 변환합니다`
* 생성 순서 : [02_create_secret.sh](manifests/02_create_secret.sh) 실행 `ex) sh 02_create_secret.sh`


## Step 3. HyperCloud Webhook Server 설치
* 목적 : `HyperCloud Webhook Server 설치`
* 생성 순서 : [03_webhook-deployment.yaml](manifests/03_webhook-deployment.yaml) 실행 `ex) kubectl apply -f 03_webhook-deployment.yaml`


## Step 4. HyperCloud Webhook Config 생성
* 목적 : `앞서 생성한 인증서 정보를 기반으로 Webhook 연동 설정 파일 생성`
* 생성 순서 : 아래의 command를 실행하여 Webhook Config를 생성한다. ([04_gen-webhook-config.sh](manifests/04_gen-webhook-config.sh))
    ```bash
    $ sh 04_gen-webhook-config.sh
    ```


## Step 5. HyperCloud Webhook Config 적용
* 목적 : `Webhook 연동 설정을 적용하여 API 서버가 Webhook Server와 HTTPS 통신을 하도록 설정`
* 생성 순서 : [05_webhook-configuration.yaml](manifests/05_webhook-configuration.yaml.template) 실행 `ex) kubectl apply -f 05_webhook-configuration.yaml`
