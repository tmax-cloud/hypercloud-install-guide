# Tekton Trigger 설치 가이드

## 구성 요소 및 버전
* controller ([gcr.io/tekton-releases/github.com/tektoncd/triggers/cmd/controller:v0.4.0](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/triggers/cmd/controller@sha256:bf3517ddccace756e39cee0f0012bbe879c6b28d962a1c904a415e7c60ce5bc2/details?tab=info))
* eventlistenersink ([gcr.io/tekton-releases/github.com/tektoncd/triggers/cmd/eventlistenersink:v0.4.0](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/triggers/cmd/eventlistenersink@sha256:76c208ec1d73d9733dcaf850240e1b3990e5977709a03c2bd98ad5b20fab9867/details?tab=info)) 
* webhook ([gcr.io/tekton-releases/github.com/tektoncd/triggers/cmd/webhook:v0.4.0](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/triggers/cmd/webhook@sha256:d7f1526a9294e671c500f0071b61e050262fb27fb633b54d764a556969855764/details?tab=info)) 


## Prerequisites
1. [Tekton Pipelines](./pipeline.md)

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. 폐쇄망에서 설치하는 경우 사용하는 image repository에 Tekton Trigger 설치 시 필요한 이미지를 push한다.
    * 작업 디렉토리 생성 및 환경 설정
    ```bash
    mkdir -p $HOME/tekton-trigger-install
    cd $HOME/tekton-trigger-install
    ```
   
   * 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받는다.
   ```bash
   # Tekton Trigger 필수 이미지 Pull
   docker pull gcr.io/tekton-releases/github.com/tektoncd/triggers/cmd/controller@sha256:bf3517ddccace756e39cee0f0012bbe879c6b28d962a1c904a415e7c60ce5bc2
   docker pull gcr.io/tekton-releases/github.com/tektoncd/triggers/cmd/eventlistenersink@sha256:76c208ec1d73d9733dcaf850240e1b3990e5977709a03c2bd98ad5b20fab9867
   docker pull gcr.io/tekton-releases/github.com/tektoncd/triggers/cmd/webhook@sha256:d7f1526a9294e671c500f0071b61e050262fb27fb633b54d764a556969855764
  
   # 이미지 태그
   docker tag gcr.io/tekton-releases/github.com/tektoncd/triggers/cmd/controller@sha256:bf3517ddccace756e39cee0f0012bbe879c6b28d962a1c904a415e7c60ce5bc2 triggers-controller:v0.4.0
   docker tag gcr.io/tekton-releases/github.com/tektoncd/triggers/cmd/eventlistenersink@sha256:76c208ec1d73d9733dcaf850240e1b3990e5977709a03c2bd98ad5b20fab9867 triggers-eventlistenersink:v0.4.0
   docker tag gcr.io/tekton-releases/github.com/tektoncd/triggers/cmd/webhook@sha256:d7f1526a9294e671c500f0071b61e050262fb27fb633b54d764a556969855764 triggers-webhook:v0.4.0

   
   # Tekton Trigger 필수 이미지 Save
   docker save triggers-controller:v0.4.0 > tekton-triggers-controller-v0.4.0.tar
   docker save triggers-eventlistenersink:v0.4.0 > tekton-triggers-eventlistenersink-v0.4.0.tar
   docker save triggers-webhook:v0.4.0 > tekton-triggers-webhook-v0.4.0.tar
   ```
   
   * install yaml을 다운로드한다.
   ```bash
    wget https://storage.googleapis.com/tekton-releases/triggers/previous/v0.4.0/release.yaml -O tekton-triggers-v0.4.0.yaml
   ```

2. 폐쇄망 환경으로 전송
    ```bash
    # 생성된 파일 모두 SCP 또는 물리 매체를 통해 폐쇄망 환경으로 복사
    scp -r $HOME/tekton-trigger-install <REMOTE_SERVER>:<PATH>
    ``` 

3. 위의 과정에서 생성한 tar 파일들을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 이미지를 push한다.
    ```bash
    # 이미지 레지스트리 주소
    REGISTRY=[IP:PORT]
    
    cd <PATH> 
    
    # Load images
    docker load < tekton-triggers-controller-v0.4.0.tar
    docker load < tekton-triggers-eventlistenersink-v0.4.0.tar
    docker load < tekton-triggers-webhook-v0.4.0.tar
    
    # Tag images
    docker tag triggers-controller:v0.4.0 $REGISTRY/triggers-controller:v0.4.0
    docker tag triggers-eventlistenersink:v0.4.0 $REGISTRY/triggers-eventlistenersink:v0.4.0
    docker tag triggers-webhook:v0.4.0 $REGISTRY/triggers-webhook:v0.4.0
    
    # Push images
    docker push $REGISTRY/triggers-controller:v0.4.0
    docker push $REGISTRY/triggers-eventlistenersink:v0.4.0
    docker push $REGISTRY/triggers-webhook:v0.4.0
    ``` 

4. YAML 수정
    ```bash
    REGISTRY=[IP:PORT]
    
    cp tekton-triggers-v0.4.0.yaml updated.yaml
    sed -i -E "s/gcr.io\/tekton-releases\/.*\/([^@]*)@[^\n\"]*/$REGISTRY\/trigger-\1:v0.4.0/g" updated.yaml
    ```

## Install Steps
1. [Trigger 설치](#step-1-trigger-설치)

## Step 1. Trigger 설치
* 목적 : `Tekton Trigger에 필요한 구성 요소 설치`
* 생성 순서 : 아래 command로 설치 yaml 적용
    * (외부망 연결된 환경 설치 시 실행)
    ```bash
    kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/previous/v0.4.0/release.yaml
    ```
    * (폐쇄망 환경 설치 시 실행)
    ```bash
    kubectl apply -f updated.yaml 
    ```
