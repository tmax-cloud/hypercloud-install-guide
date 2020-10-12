# Mail-Notifier for CI/CD 설치 가이드

## 구성 요소 및 버전
* mail-sender-server ([tmaxcloudck/mail-sender-server:v0.0.4](https://hub.docker.com/layers/tmaxcloudck/mail-sender-server/v0.0.4/images/sha256-3d87f419d056132690bd7cdcb5aab1abe0021ae12b4efd50a8b7c0be7a44dd86?context=explore))
* mail-sender-client ([tmaxcloudck/mail-sender-client:v0.0.4](https://hub.docker.com/layers/tmaxcloudck/mail-sender-client/v0.0.4/images/sha256-0364005e432a67e839cee04cdb0ebb5d925eb4427fd248f346566300f890d046?context=explore))

## Prerequisites

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. 폐쇄망에서 설치하는 경우 사용하는 image repository에 Approval-watcher 설치 시 필요한 이미지를 push한다.
    * 작업 디렉토리 생성 및 환경 설정
    ```bash
    mkdir -p $HOME/mail-install
    cd $HOME/mail-install
    ```
    * 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받는다.
    ```bash
    # Mail Notifier 필수 이미지 Pull
    docker pull tmaxcloudck/mail-sender-server:v0.0.4
    docker pull tmaxcloudck/mail-sender-client:v0.0.4
   
    # 이미지 태그
    docker tag tmaxcloudck/mail-sender-server:v0.0.4 mail-sender-server:v0.0.4
    docker tag tmaxcloudck/mail-sender-client:v0.0.4 mail-sender-client:v0.0.4
    
    # Mail Notifier 필수 이미지 Save
    docker save mail-sender-server:v0.0.4 > mail-sender-server-v0.0.4.tar
    docker save mail-sender-client:v0.0.4 > mail-sender-client-v0.0.4.tar
    ```
    * install yaml을 다운로드한다.
    ```bash
    wget https://raw.githubusercontent.com/cqbqdd11519/mail-notifier/master/deploy/service.yaml
    wget https://raw.githubusercontent.com/cqbqdd11519/mail-notifier/master/deploy/server.yaml
    wget https://raw.githubusercontent.com/cqbqdd11519/mail-notifier/master/deploy/secret.yaml.template
    ```

2. 폐쇄망 환경으로 전송
    ```bash
    # 생성된 파일 모두 SCP 또는 물리 매체를 통해 폐쇄망 환경으로 복사
    scp -r $HOME/mail-install <REMOTE_SERVER>:<PATH>
    ``` 

3. 위의 과정에서 생성한 tar 파일들을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 이미지를 push한다.
    ```bash
    # 이미지 레지스트리 주소
    REGISTRY=[IP:PORT]
   
    cd <PATH> 
    
    # Load images
    docker load < mail-sender-server-v0.0.4.tar
    docker load < mail-sender-client-v0.0.4.tar
    
    # Tag images
    docker tag mail-sender-server:v0.0.4 $REGISTRY/mail-sender-server:v0.0.4
    docker tag mail-sender-client:v0.0.4 $REGISTRY/mail-sender-client:v0.0.4
    
    # Push images
    docker push $REGISTRY/mail-sender-server:v0.0.4
    docker push $REGISTRY/mail-sender-client:v0.0.4
    ```
4. YAML 수정
    ```bash
    REGISTRY=[IP:PORT]
    
    cp server.yaml updated.yaml
    sed -i "s/tmaxcloudck\/mail-sender-server:v0.0.3/$REGISTRY\/mail-sender-server:v0.0.3/g" updated.yaml
    ```

## Install Steps
1. [SMTP 서버 설정](#step-1-smtp-서버-설정)
2. [Mail Notifier Server 설치](#step-2-Server-설치)

## Step 1. SMTP 서버 설정
* 목적 : `Mail-notifier에서 사용할 외부 SMTP 서버 설정`
* 생성 순서 : 아래 command로 설정
    * (외부망 연결된 환경 설치 시 실행)
    ```bash
    SMTP_SERVER=<SMTP Server Address>
    SMTP_USER=<SMTP User ID>
    SMTP_PW=<SMTP User PW>
    NAMESPACE=approval-system
    
    curl https://raw.githubusercontent.com/cqbqdd11519/mail-notifier/master/deploy/secret.yaml.template -s | \
    sed "s/<SMTP Address (IP:PORT)>/'${SMTP_SERVER}'/g" | \
    sed "s/<SMTP User ID>/'${SMTP_USER}'/g" | \
    sed "s/<SMTP User PW>/'${SMTP_PW}'/g" | \
    kubectl apply --namespace ${NAMESPACE} -f -
    ```
    * (폐쇄망 환경 설치 시 실행)
    ```bash
    SMTP_SERVER=<SMTP Server Address>
    SMTP_USER=<SMTP User ID>
    SMTP_PW=<SMTP User PW>
    NAMESPACE=approval-system

    cp secret.yaml.template secret.yaml
    sed -i "s/<SMTP Address (IP:PORT)>/'${SMTP_SERVER}'/g" secret.yaml
    sed -i "s/<SMTP User ID>/'${SMTP_USER}'/g" secret.yaml
    sed - i"s/<SMTP User PW>/'${SMTP_PW}'/g" secret.yaml
    kubectl apply --namespace ${NAMESPACE} -f secret.yaml
    ```

## Step 2. Server 설치
* 목적 : `Mail-notifier 구성 요소 설치`
* 생성 순서 : 아래 command로 설치 yaml 적용
    * (외부망 연결된 환경 설치 시 실행)
    ```bash
    NAMESPACE=approval-system
    kubectl apply --namespace ${NAMESPACE} --filename https://raw.githubusercontent.com/cqbqdd11519/mail-notifier/master/deploy/service.yaml
    kubectl apply --namespace ${NAMESPACE} --filename https://raw.githubusercontent.com/cqbqdd11519/mail-notifier/master/deploy/server.yaml
    ```
    * (폐쇄망 환경 설치 시 실행)
    ```bash
    NAMESPACE=approval-system
    kubectl apply --namespace ${NAMESPACE} -f service.yaml
    kubectl apply --namespace ${NAMESPACE} -f updated.yaml
    ```
