# HyperAuth 설치 가이드

## 구성 요소 및 버전
* hyperauth
    * ([tmaxcloudck/hyperauth:b1.0.2.5](https://hub.docker.com/layers/tmaxcloudck/hyperauth/b1.0.2.5/images/sha256-ac5297490881a49849b1c9c58f5d2e94fe1acc4406939be9310400bc9563a6a9?context=explore)) 

## Prerequisites
X

## Dependencies
openssl binary

csi-cephfs-sc storageClass

LoadBalancer type의 service 생성 가능

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. 사용하는 image repository에 HyperAuth 설치 시 필요한 이미지를 push한다. 


## Install Steps
1. [초기화 작업]()
2. [SSL 인증서 생성]()
4. [HyperAuth Deployment 생성]()
5. [Kubernetes OIDC 연동]()

## Step 1. 초기화 작업
* 목적 : `HyperAuth 구축을 위한 초기화 작업 및 DB 구축`
* 생성 순서 : [1.initialization.yaml](manifest/1.initialization.yaml) 실행 `ex) kubectl apply -f 1.initialization.yaml`)
* 비고 : 아래 커맨드 수행 후, Postgre DB table 생성 확인 (약 96-97개)
```bash
    $ kubectl exec -it $(kubectl get pods -n hyperauth | grep postgre | cut -d ' ' -f1) -n hyperauth -- bash
    $ psql -U keycloak keycloak
    $ \dt
 ```

## Step 2. SSL 인증서 생성
* 목적 : `HTTPS 인증을 위한 openssl 인증서를 생성하고 secret으로 변환`
* 생성 순서 : 아래 커맨드를 실행하여 인증서 생성 및 secret을 생성 (특정 directory 내부에서 실행 권장)
```bash
    $ openssl req -newkey rsa:4096 -nodes -sha256 -keyout hyperauth.key -x509 -subj "/C=KR/ST=Seoul/O=tmax/CN={HYPERAUTH_SERVICE_IP}" -days 365 -config <(cat /etc/ssl/openssl.cnf <(printf "[v3_ca]\nsubjectAltName=IP:$(kubectl describe service hyperauth -n hyperauth | grep 'LoadBalancer Ingress' | cut -d ' ' -f7)")) -out hyperauth.crt
    $ kubectl create secret tls hyperauth-https-secret --cert=./hyperauth.crt --key=./hyperauth.key -n hyperauth
    $ cp hyperauth.crt /etc/kubernetes/pki/hyperauth.crt
```


## Step 3. HyperAuth Deployment 배포
* 목적 : `HyperCloud Webhook Server 설치`
* 생성 순서 : [2.hyperauth_deployment.yaml](manifests/2.hyperauth_deployment.yaml) 실행 `ex) kubectl apply -f 2.hyperauth_deployment.yaml`
* 비고 :
    * kubectl get svc hyperauth -n hyperauth 명령어의 IP로 접속하여 정상 기동 확인
    * 계정 : admin/admin


## Step 4. Kubernetes OIDC 연동
* 목적 : `앞서 생성한 인증서 정보를 기반으로 Webhook 연동 설정 파일 생성`
* 생성 순서 : 아래의 command를 실행하여 Webhook Config를 생성한다. ([04_gen-webhook-config.sh](manifests/04_gen-webhook-config.sh))
    ```bash
    $ sh 04_gen-webhook-config.sh
    ```
    
