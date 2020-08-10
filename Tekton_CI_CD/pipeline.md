# Tekton Pipelines 설치 가이드

## 구성 요소 및 버전
* controller ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/controller:v0.12.1](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/cmd/controller@sha256:0ca86ec6f246f49c1ac643357fd1c8e73a474aaa216548807b1216a9ff12f7be/details?tab=info))
* kubeconfigwriter ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/kubeconfigwriter:v0.12.1](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/cmd/kubeconfigwriter@sha256:67dcd447b0c624befa12843ce9cc0bcfc502179bdb28d59563d761a7f3968509/details?tab=info))
* creds-init ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/creds-init:v0.12.1](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/cmd/creds-init@sha256:6266d023172dde7fa421f626074b4e7eedc7d7d5ff561c033d6d63ebfff4a2f2/details?tab=info))
* git-init ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/git-init:v0.12.1](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/cmd/git-init@sha256:d82c78288699dd6ee40c852b146cb3bd89b322b42fb3bc4feec28ea54bb7b36c/details?tab=info))
* entrypoint ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/entrypoint:v0.12.1](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/cmd/entrypoint@sha256:7f3db925f7660673a74b0e1030e65540adea36fe361ab7f06f5b5c47cdcef47d/details?tab=info))
* imagedigestexporter ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/imagedigestexporter:v0.12.1](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/cmd/imagedigestexporter@sha256:e8f08214baad9054bbed7be2b8617c6964b9a1c5405cf59eabcc3d3267a6253f/details?tab=info))
* pillrequest-init ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/pullrequest-init:v0.12.1](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/cmd/pullrequest-init@sha256:71e0226346e0d3d57af7c35b6cb907d42d3142e845b0f865ba0c86d3e248f3cb/details?tab=info))
* gcs-fetcher ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/vendor/github.com/googlecloudplatform/cloud-builders/gcs-fetcher/cmd/gcs-fetcher:v0.12.1](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/vendor/github.com/googlecloudplatform/cloud-builders/gcs-fetcher/cmd/gcs-fetcher@sha256:ae5721bf0d883947c3c13f519ca26129792f4058d5f9dfedd50174d9e7acb2bc/details?tab=info))
* webhook ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/webhook:v0.12.1](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/cmd/webhook@sha256:69f065d493244dbd50563b96f5474bf6590821a6308fd8c69c5ef06cf4d988b2/details?tab=info))
* tianon/true ([docker.io/tianon/true:latest](https://hub.docker.com/layers/tianon/true/latest/images/sha256-183cb5fd54142948ad88cc986a217465cfe8786cfdd89b1ed1fc49825da413a7?context=explore))
* busybox ([docker.io/busybox:latest](https://hub.docker.com/layers/busybox/library/busybox/latest/images/sha256-116dccaef9ca8b121565a39bd568ede437f084c94bb0642d2aba6b441e38d2f8?context=explore))
* google/cloud-sdk ([docker.io/google/cloud-sdk:289.0.0](https://hub.docker.com/layers/google/cloud-sdk/289.0.0/images/sha256-6e8676464c7581b2dc824956b112a61c95e4144642bec035e6db38e3384cae2e?context=explore))

## Prerequisites

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. 폐쇄망에서 설치하는 경우 사용하는 image repository에 Tekton Pipelines 설치 시 필요한 이미지를 push한다.
    * 작업 디렉토리 생성 및 환경 설정
    ```bash
    mkdir -p $HOME/tekton-install
    cd $HOME/tekton-install
    ```
    * 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받는다.
    ```bash
    # Tekton Pipleine 필수 이미지 Pull
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/controller:v0.12.1@sha256:0ca86ec6f246f49c1ac643357fd1c8e73a474aaa216548807b1216a9ff12f7be
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/kubeconfigwriter:v0.12.1@sha256:67dcd447b0c624befa12843ce9cc0bcfc502179bdb28d59563d761a7f3968509
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/creds-init:v0.12.1@sha256:6266d023172dde7fa421f626074b4e7eedc7d7d5ff561c033d6d63ebfff4a2f2
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/git-init:v0.12.1@sha256:d82c78288699dd6ee40c852b146cb3bd89b322b42fb3bc4feec28ea54bb7b36c
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/entrypoint:v0.12.1@sha256:7f3db925f7660673a74b0e1030e65540adea36fe361ab7f06f5b5c47cdcef47d
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/imagedigestexporter:v0.12.1@sha256:e8f08214baad9054bbed7be2b8617c6964b9a1c5405cf59eabcc3d3267a6253f
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/pullrequest-init:v0.12.1@sha256:71e0226346e0d3d57af7c35b6cb907d42d3142e845b0f865ba0c86d3e248f3cb
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/vendor/github.com/googlecloudplatform/cloud-builders/gcs-fetcher/cmd/gcs-fetcher:v0.12.1@sha256:ae5721bf0d883947c3c13f519ca26129792f4058d5f9dfedd50174d9e7acb2bc
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/webhook:v0.12.1@sha256:69f065d493244dbd50563b96f5474bf6590821a6308fd8c69c5ef06cf4d988b2
    docker pull tianon/true
    docker pull busybox
    docker pull google/cloud-sdk:289.0.0
   
    # 이미지 태그
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/controller:v0.12.1@sha256:0ca86ec6f246f49c1ac643357fd1c8e73a474aaa216548807b1216a9ff12f7be controller:v0.12.1
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/kubeconfigwriter:v0.12.1@sha256:67dcd447b0c624befa12843ce9cc0bcfc502179bdb28d59563d761a7f3968509 kubeconfigwriter:v0.12.1
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/creds-init:v0.12.1@sha256:6266d023172dde7fa421f626074b4e7eedc7d7d5ff561c033d6d63ebfff4a2f2 creds-init:v0.12.1
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/git-init:v0.12.1@sha256:d82c78288699dd6ee40c852b146cb3bd89b322b42fb3bc4feec28ea54bb7b36c git-init:v0.12.1
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/entrypoint:v0.12.1@sha256:7f3db925f7660673a74b0e1030e65540adea36fe361ab7f06f5b5c47cdcef47d entrypoint:v0.12.1
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/imagedigestexporter:v0.12.1@sha256:e8f08214baad9054bbed7be2b8617c6964b9a1c5405cf59eabcc3d3267a6253f imagedigestexporter:v0.12.1
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/pullrequest-init:v0.12.1@sha256:71e0226346e0d3d57af7c35b6cb907d42d3142e845b0f865ba0c86d3e248f3cb pullrequest-init:v0.12.1
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/vendor/github.com/googlecloudplatform/cloud-builders/gcs-fetcher/cmd/gcs-fetcher:v0.12.1@sha256:ae5721bf0d883947c3c13f519ca26129792f4058d5f9dfedd50174d9e7acb2bc gcs-fetcher:v0.12.1
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/webhook:v0.12.1@sha256:69f065d493244dbd50563b96f5474bf6590821a6308fd8c69c5ef06cf4d988b2 webhook:v0.12.1
    docker tag tianon/true tianon-true:v0.12.1
    docker tag busybox busybox:v0.12.1
    docker tag google/cloud-sdk:289.0.0 google-cloud-sdk:v0.12.1
    
    # Tekton Pipleine 필수 이미지 Save
    docker save controller:v0.12.1 > tekton-pipeline-controller-v0.12.1.tar
    docker save kubeconfigwriter:v0.12.1 > tekton-pipeline-kubeconfigwriter-v0.12.1.tar
    docker save creds-init:v0.12.1 > tekton-pipeline-creds-init-v0.12.1.tar
    docker save git-init:v0.12.1 > tekton-pipeline-git-init-v0.12.1.tar
    docker save entrypoint:v0.12.1 > tekton-pipeline-entrypoint-v0.12.1.tar
    docker save imagedigestexporter:v0.12.1 > tekton-pipeline-imagedigestexporter-v0.12.1.tar
    docker save pullrequest-init:v0.12.1 > tekton-pipeline-pullrequest-init-v0.12.1.tar
    docker save gcs-fetcher:v0.12.1 > tekton-pipeline-gcs-fetcher-v0.12.1.tar
    docker save webhook:v0.12.1 > tekton-pipeline-webhook-v0.12.1.tar
    docker save tianon-true:v0.12.1 > tekton-pipeline-tianon-true-v0.12.1.tar
    docker save busybox:v0.12.1 > tekton-pipeline-busybox-v0.12.1.tar
    docker save google-cloud-sdk:v0.12.1 > tekton-pipeline-google-cloud-sdk-v0.12.1.tar
    ```
    * install yaml을 다운로드한다.
    ```bash
    wget https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.12.1/release.yaml -O tekton-pipeline-v0.12.1.yaml 
    ```

2. 폐쇄망 환경으로 전송
    ```bash
    # 생성된 파일 모두 SCP 또는 물리 매체를 통해 폐쇄망 환경으로 복사
    scp -r $HOME/tekton-install <REMOTE_SERVER>:<PATH>
    ``` 

3. 위의 과정에서 생성한 tar 파일들을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 이미지를 push한다.
    ```bash
    # 이미지 레지스트리 주소
    REGISTRY=[IP:PORT]
   
    cd <PATH> 
    
    # Load images
    docker load < tekton-pipeline-controller-v0.12.1.tar
    docker load < tekton-pipeline-kubeconfigwriter-v0.12.1.tar
    docker load < tekton-pipeline-creds-init-v0.12.1.tar
    docker load < tekton-pipeline-git-init-v0.12.1.tar
    docker load < tekton-pipeline-entrypoint-v0.12.1.tar
    docker load < tekton-pipeline-imagedigestexporter-v0.12.1.tar
    docker load < tekton-pipeline-pullrequest-init-v0.12.1.tar
    docker load < tekton-pipeline-gcs-fetcher-v0.12.1.tar
    docker load < tekton-pipeline-webhook-v0.12.1.tar
    docker load < tekton-pipeline-tianon-true-v0.12.1.tar
    docker load < tekton-pipeline-busybox-v0.12.1.tar
    docker load < tekton-pipeline-google-cloud-sdk-v0.12.1.tar
    
    # Tag images
    docker tag controller:v0.12.1 $REGISTRY/controller:v0.12.1
    docker tag kubeconfigwriter:v0.12.1 $REGISTRY/kubeconfigwriter:v0.12.1
    docker tag creds-init:v0.12.1 $REGISTRY/creds-init:v0.12.1
    docker tag git-init:v0.12.1 $REGISTRY/git-init:v0.12.1
    docker tag entrypoint:v0.12.1 $REGISTRY/entrypoint:v0.12.1
    docker tag imagedigestexporter:v0.12.1 $REGISTRY/imagedigestexporter:v0.12.1
    docker tag pullrequest-init:v0.12.1 $REGISTRY/pullrequest-init:v0.12.1
    docker tag gcs-fetcher:v0.12.1 $REGISTRY/gcs-fetcher:v0.12.1
    docker tag webhook:v0.12.1 $REGISTRY/webhook:v0.12.1
    docker tag tianon-true:v0.12.1 $REGISTRY/tianon-true:v0.12.1
    docker tag busybox:v0.12.1 $REGISTRY/busybox:v0.12.1
    docker tag google-cloud-sdk:v0.12.1 $REGISTRY/google-cloud-sdk:v0.12.1
    
    # Push images
    docker push $REGISTRY/controller:v0.12.1
    docker push $REGISTRY/kubeconfigwriter:v0.12.1
    docker push $REGISTRY/creds-init:v0.12.1
    docker push $REGISTRY/git-init:v0.12.1
    docker push $REGISTRY/entrypoint:v0.12.1
    docker push $REGISTRY/imagedigestexporter:v0.12.1
    docker push $REGISTRY/pullrequest-init:v0.12.1
    docker push $REGISTRY/gcs-fetcher:v0.12.1
    docker push $REGISTRY/webhook:v0.12.1
    docker push $REGISTRY/tianon-true:v0.12.1
    docker push $REGISTRY/busybox:v0.12.1
    docker push $REGISTRY/google-cloud-sdk:v0.12.1
    ```
4. YAML 수정
    ```bash
    REGISTRY=[IP:PORT]
    
    cp tekton-pipeline-v0.12.1.yaml updated.yaml
    sed -i -E "s/gcr.io\/tekton-releases\/.*\/([^@]*)@[^\n\"]*/$REGISTRY\/\1/g" updated.yaml
    sed -i "s/tianon\/true@[^\n\"]*/$REGISTRY\/tianon-true:v0.12.1/g" updated.yaml
    sed -i "s/busybox@[^\n\"]*/$REGISTRY\/busybox:v0.12.1/g" updated.yaml
    sed -i "s/google\/cloud-sdk@[^\n\"]*/$REGISTRY\/google-cloud-sdk:v0.12.1/g" updated.yaml
    ```

## Install Steps
1. [Pipelines 설치](#step-1-pipelines-설치)

## Step 1. Pipelines 설치
* 목적 : `Tekton Pipelines에 필요한 구성 요소 설치`
* 생성 순서 : 아래 command로 설치 yaml 적용
    * (외부망 연결된 환경 설치 시 실행)
    ```bash
    kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.12.1/release.yaml
    ```
    * (폐쇄망 환경 설치 시 실행)
    ```bash
    kubectl apply -f updated.yaml 
    ```
