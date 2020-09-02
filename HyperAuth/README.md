# HyperAuth 설치 가이드

## 구성 요소 및 버전
* hyperauth
    * ([tmaxcloudck/hyperauth:b1.0.2.5](https://hub.docker.com/layers/tmaxcloudck/hyperauth/b1.0.2.5/images/sha256-ac5297490881a49849b1c9c58f5d2e94fe1acc4406939be9310400bc9563a6a9?context=explore)) 

## Prerequisites
X

## Dependencies
X

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. **폐쇄망에서 설치하는 경우** 사용하는 image repository에 HyperCloud Webhook 설치 시 필요한 이미지를 push한다. 

    * 작업 디렉토리 생성 및 환경 설정
    ```bash
    $ mkdir -p ~/hypercloud-webhook-install
    $ export WEBHOOK_HOME=~/hypercloud-webhook-install
    $ export WEBHOOK_VERSION=b4.1.0.14
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
    
3. 해당 환경에 JAVA가 설치되어 있지 않을 경우, 첨부된 JAVA 파일을 활용하여 JAVA 기반 cli - keytool을 설치한다. ([java](pkg/jre1.8.0_251))
    ```bash
    $ sudo mkdir /usr/local/java
    
    $ sudo mv jre1.8.0_251 /usr/local/java/
    
    $ sudo /bin/su -c "echo 'export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")' >> /etc/profile"
    
    $ sudo chmod 755 /usr/local/java/jre1.8.0_251/bin/keytool
    
    $ sudo update-alternatives --install "/usr/bin/keytool" "keytool" "/usr/local/java/jre1.8.0_251/bin/keytool" 1;
    
    $ sudo update-alternatives --set keytool /usr/local/java/jre1.8.0_251/bin/keytool;
    ```    
    

## Install Steps
0. [hypercloud-webhook yaml 수정](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/HyperCloud%20Webhook#step-0-hypercloud-webhook-yaml-%EC%88%98%EC%A0%95)
1. [인증서 생성](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/HyperCloud%20Webhook#step-1-%EC%9D%B8%EC%A6%9D%EC%84%9C-%EC%83%9D%EC%84%B1)
2. [Secret 생성](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/HyperCloud%20Webhook#step-2-secret-%EC%83%9D%EC%84%B1)
3. [HyperCloud Webhook Server 설치](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/HyperCloud%20Webhook#step-3-hypercloud-webhook-server-%EC%84%A4%EC%B9%98)
4. [HyperCloud Webhook Config 생성](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/HyperCloud%20Webhook#step-4-hypercloud-webhook-config-%EC%83%9D%EC%84%B1)
5. [HyperCloud Webhook Config 적용](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/HyperCloud%20Webhook#step-5-hypercloud-webhook-config-%EC%A0%81%EC%9A%A9)
6. [test-yaml 배포](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/HyperCloud%20Webhook#step-6-test-yaml-%EB%B0%B0%ED%8F%AC)

## Step 0. hypercloud-webhook yaml 수정
* 목적 : `hypercloud-webhook yaml에 이미지 registry, 버전 및 마스터 노드 정보를 수정` ([manifests](manifests) 디렉토리 참고)
* 생성 순서 : 아래의 command를 실행하여 사용하고자 하는 image 버전을 수정한다. ([03_webhook-deployment.yaml](manifests/03_webhook-deployment.yaml))
    ```bash
    $ sed -i 's/{webhook_version}/'${WEBHOOK_VERSION}'/g' 03_webhook-deployment.yaml
    $ sed -i 's/{hostname}/'${HOSTNAME}'/g' 03_webhook-deployment.yaml
    ```
* 비고 :
    * 폐쇄망에서 설치를 진행하여 별도의 image registry를 사용하는 경우 registry 정보를 추가로 설정해준다.
	```bash
	$ sed -i 's/tmaxcloudck\/hypercloud-webhook/'${REGISTRY}'\/hypercloud-webhook/g' 03_webhook-deployment.yaml
	```

## Step 1. 인증서 생성
* 목적 : `HTTPS 활성화를 위한 CA 인증서를 생성`
* 생성 순서 : 아래의 command를 실행하여 CA 인증서를 생성한다. ([01_gen_certs.sh](manifests/01_gen_certs.sh))
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
