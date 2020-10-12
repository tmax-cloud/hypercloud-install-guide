# Approval for CI/CD 설치 가이드

## 구성 요소 및 버전
* approval-watcher ([tmaxcloudck/approval-watcher:0.0.3](https://hub.docker.com/layers/tmaxcloudck/approval-watcher/0.0.3/images/sha256-6f5fd3fbe9f45909954181a9121321bbf13dc5f46724a6ad72bb156754cac2c6?context=explore))
* approval-step-server ([tmaxcloudck/approval-step-server:0.0.3](https://hub.docker.com/layers/tmaxcloudck/approval-step-server/0.0.3/images/sha256-dd1eca762c7009676c2ae41d409ee084e803eefe40581ad95463f20a88bc0a59?context=explore))

## Prerequisites

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. 폐쇄망에서 설치하는 경우 사용하는 image repository에 Approval-watcher 설치 시 필요한 이미지를 push한다.
    * 작업 디렉토리 생성 및 환경 설정
    ```bash
    mkdir -p $HOME/approval-install
    cd $HOME/approval-install
    ```
    * 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받는다.
    ```bash
    # Approval 필수 이미지 Pull
    docker pull tmaxcloudck/approval-watcher:0.0.3
    docker pull tmaxcloudck/approval-step-server:0.0.3
   
    # 이미지 태그
    docker tag tmaxcloudck/approval-watcher:0.0.3 approval-watcher:0.0.3
    docker tag tmaxcloudck/approval-step-server:0.0.3 approval-step-server:0.0.3
    
    # Approval 필수 이미지 Save
    docker save approval-watcher:0.0.3 > approval-watcher-0.0.3.tar
    docker save approval-step-server:0.0.3 > approval-step-server-0.0.3.tar
    ```
    * install yaml을 다운로드한다.
    ```bash
    wget https://raw.githubusercontent.com/tmax-cloud/approval-watcher/master/deploy/crds/tmax.io_approvals_crd.yaml crd.yaml
    wget https://raw.githubusercontent.com/tmax-cloud/approval-watcher/master/deploy/namespace.yaml
    wget https://raw.githubusercontent.com/tmax-cloud/approval-watcher/master/deploy/service_account.yaml
    wget https://raw.githubusercontent.com/tmax-cloud/approval-watcher/master/deploy/role.yaml
    wget https://raw.githubusercontent.com/tmax-cloud/approval-watcher/master/deploy/role_binding.yaml
    wget https://raw.githubusercontent.com/tmax-cloud/approval-watcher/master/deploy/service.yaml
    wget https://raw.githubusercontent.com/tmax-cloud/approval-watcher/master/deploy/proxy-server.yaml
    ```

2. 폐쇄망 환경으로 전송
    ```bash
    # 생성된 파일 모두 SCP 또는 물리 매체를 통해 폐쇄망 환경으로 복사
    scp -r $HOME/approval-install <REMOTE_SERVER>:<PATH>
    ``` 

3. 위의 과정에서 생성한 tar 파일들을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 이미지를 push한다.
    ```bash
    # 이미지 레지스트리 주소
    REGISTRY=[IP:PORT]
   
    cd <PATH> 
    
    # Load images
    docker load < approval-watcher-0.0.3.tar
    docker load < approval-step-server-0.0.3.tar
    
    # Tag images
    docker tag approval-watcher:0.0.3 $REGISTRY/approval-watcher:0.0.3
    docker tag approval-step-server:0.0.3 $REGISTRY/approval-step-server:0.0.3
    
    # Push images
    docker push $REGISTRY/approval-watcher:0.0.3
    docker push $REGISTRY/approval-step-server:0.0.3
    ```
4. YAML 수정
    ```bash
    REGISTRY=[IP:PORT]
    
    cp proxy-server.yaml updated.yaml
    sed -i "s/tmaxcloudck\/approval-watcher:latest/$REGISTRY\/approval-watcher:0.0.3/g" updated.yaml
    ```

## Install Steps
1. [Approval 설치](#step-1-approval-설치)

## Step 1. Approval 설치
* 목적 : `단계 별 승인에 필요한 구성 요소 설치`
* 생성 순서 : 아래 command로 설치 yaml 적용
    * (외부망 연결된 환경 설치 시 실행)
    ```bash
    kubectl apply -f https://raw.githubusercontent.com/tmax-cloud/approval-watcher/master/deploy/crds/tmax.io_approvals_crd.yaml
    kubectl apply -f https://raw.githubusercontent.com/tmax-cloud/approval-watcher/master/deploy/namespace.yaml
    kubectl apply -f https://raw.githubusercontent.com/tmax-cloud/approval-watcher/master/deploy/service_account.yaml
    kubectl apply -f https://raw.githubusercontent.com/tmax-cloud/approval-watcher/master/deploy/role.yaml
    kubectl apply -f https://raw.githubusercontent.com/tmax-cloud/approval-watcher/master/deploy/role_binding.yaml
    kubectl apply -f https://raw.githubusercontent.com/tmax-cloud/approval-watcher/master/deploy/service.yaml
    kubectl apply -f https://raw.githubusercontent.com/tmax-cloud/approval-watcher/master/deploy/proxy-server.yaml
    ```
    * (폐쇄망 환경 설치 시 실행)
    ```bash
    kubectl apply -f crd.yaml
    kubectl apply -f namespace.yaml
    kubectl apply -f service_account.yaml
    kubectl apply -f role.yaml
    kubectl apply -f role_binding.yaml
    kubectl apply -f service.yaml
    kubectl apply -f updated.yaml
    ```
