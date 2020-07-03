# Tekton Pipelines 설치 가이드

## 구성 요소 및 버전
* controller ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/controller:v0.11.2](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/cmd/controller@sha256:0791513ec1176da38c403eb81220406e987f78f3e58608bd57be1adc45bc9aac/details?tab=info))
* kubeconfigwriter ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/kubeconfigwriter:v0.11.2](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/cmd/kubeconfigwriter@sha256:d01fa1db8abcad318d05e62e35153a91c6c995949e52133520d9e4735e9a486c/details?tab=info))
* creds-init ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/creds-init:v0.11.2](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/cmd/creds-init@sha256:ced427e48b143bc821aedd4a0936fa2caef3f208d70efe68ccba786c12b2c943/details?tab=info))
* git-init ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/git-init:v0.11.2](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/cmd/git-init@sha256:bee98bfe6807e8f4e0a31b4e786fd1f7f459e653ed1a22b1a25999f33fa9134a/details?tab=info))
* entrypoint ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/entrypoint:v0.11.2](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/cmd/entrypoint@sha256:bc5beb48ca4f87013ccb466bf739d6c99ef9f1ddf51899c73ead99f242b4e57d/details?tab=info))
* imagedigestexporter ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/imagedigestexporter:v0.11.2](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/cmd/imagedigestexporter@sha256:7a03343deaeaa6b2d779df37417f9bf76cb5f67b36dd298e5bb69a0f625a2b38?tag=v0.11.2))
* pillrequest-init ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/pullrequest-init:v0.11.2](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/cmd/pullrequest-init@sha256:3a395509e0d75786eafe96f68d22afc7c4d23a2a76ffc77218b25e8c6c81f6ba/details?tab=info))
* gcs-fetcher ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/vendor/github.com/googlecloudplatform/cloud-builders/gcs-fetcher/cmd/gcs-fetcher:v0.11.2](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/vendor/github.com/googlecloudplatform/cloud-builders/gcs-fetcher/cmd/gcs-fetcher@sha256:a020c8510b15870a5b059708197ac7c4ef0d1cbd668eb0872105ad658d509f67/details?tab=info))
* webhook ([gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/webhook:v0.11.2](https://console.cloud.google.com/gcr/images/tekton-releases/GLOBAL/github.com/tektoncd/pipeline/cmd/webhook@sha256:9826548f3bd8cc0c4187ca0ab5ab8114009874625828a23301c1f60be4f294fa/details?tab=info))
* tianon/true ([docker.io/tianon/true:latest](https://hub.docker.com/layers/tianon/true/latest/images/sha256-183cb5fd54142948ad88cc986a217465cfe8786cfdd89b1ed1fc49825da413a7?context=explore))
* busybox ([docker.io/busybox:latest](https://hub.docker.com/layers/busybox/library/busybox/latest/images/sha256-116dccaef9ca8b121565a39bd568ede437f084c94bb0642d2aba6b441e38d2f8?context=explore))
* google/cloud-sdk ([docker.io/google/cloud-sdk:latest](https://hub.docker.com/layers/google/cloud-sdk/latest/images/sha256-e2c4eb48f27df773b6dab13a635859608914ddf22a2ad3aad1211f9099999e28?context=explore))

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
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/controller:v0.11.2@sha256:0791513ec1176da38c403eb81220406e987f78f3e58608bd57be1adc45bc9aac
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/kubeconfigwriter:v0.11.2@sha256:d01fa1db8abcad318d05e62e35153a91c6c995949e52133520d9e4735e9a486c
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/creds-init:v0.11.2@sha256:ced427e48b143bc821aedd4a0936fa2caef3f208d70efe68ccba786c12b2c943
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/git-init:v0.11.2@sha256:bee98bfe6807e8f4e0a31b4e786fd1f7f459e653ed1a22b1a25999f33fa9134a
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/entrypoint:v0.11.2@sha256:bc5beb48ca4f87013ccb466bf739d6c99ef9f1ddf51899c73ead99f242b4e57d
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/imagedigestexporter:v0.11.2@sha256:7a03343deaeaa6b2d779df37417f9bf76cb5f67b36dd298e5bb69a0f625a2b38
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/pullrequest-init:v0.11.2@sha256:3a395509e0d75786eafe96f68d22afc7c4d23a2a76ffc77218b25e8c6c81f6ba
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/vendor/github.com/googlecloudplatform/cloud-builders/gcs-fetcher/cmd/gcs-fetcher:v0.11.2@sha256:a020c8510b15870a5b059708197ac7c4ef0d1cbd668eb0872105ad658d509f67
    docker pull gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/webhook:v0.11.2@sha256:9826548f3bd8cc0c4187ca0ab5ab8114009874625828a23301c1f60be4f294fa
    docker pull tianon/true
    docker pull busybox
    docker pull google/cloud-sdk
   
    # 이미지 태그
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/controller:v0.11.2@sha256:0791513ec1176da38c403eb81220406e987f78f3e58608bd57be1adc45bc9aac controller:v0.11.2
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/kubeconfigwriter:v0.11.2@sha256:d01fa1db8abcad318d05e62e35153a91c6c995949e52133520d9e4735e9a486c kubeconfigwriter:v0.11.2
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/creds-init:v0.11.2@sha256:ced427e48b143bc821aedd4a0936fa2caef3f208d70efe68ccba786c12b2c943 creds-init:v0.11.2
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/git-init:v0.11.2@sha256:bee98bfe6807e8f4e0a31b4e786fd1f7f459e653ed1a22b1a25999f33fa9134a git-init:v0.11.2
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/entrypoint:v0.11.2@sha256:bc5beb48ca4f87013ccb466bf739d6c99ef9f1ddf51899c73ead99f242b4e57d entrypoint:v0.11.2
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/imagedigestexporter:v0.11.2@sha256:7a03343deaeaa6b2d779df37417f9bf76cb5f67b36dd298e5bb69a0f625a2b38 imagedigestexporter:v0.11.2
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/pullrequest-init:v0.11.2@sha256:3a395509e0d75786eafe96f68d22afc7c4d23a2a76ffc77218b25e8c6c81f6ba pullrequest-init:v0.11.2
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/vendor/github.com/googlecloudplatform/cloud-builders/gcs-fetcher/cmd/gcs-fetcher:v0.11.2@sha256:a020c8510b15870a5b059708197ac7c4ef0d1cbd668eb0872105ad658d509f67 gcs-fetcher:v0.11.2
    docker tag gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/webhook:v0.11.2@sha256:9826548f3bd8cc0c4187ca0ab5ab8114009874625828a23301c1f60be4f294fa webhook:v0.11.2
    docker tag tianon/true tianon-true:v0.11.2
    docker tag busybox busybox:v0.11.2
    docker tag google/cloud-sdk google-cloud-sdk:v0.11.2
    
    # Tekton Pipleine 필수 이미지 Save
    docker save controller:v0.11.2 > tekton-pipeline-controller-v0.11.2.tar
    docker save kubeconfigwriter:v0.11.2 > tekton-pipeline-kubeconfigwriter-v0.11.2.tar
    docker save creds-init:v0.11.2 > tekton-pipeline-creds-init-v0.11.2.tar
    docker save git-init:v0.11.2 > tekton-pipeline-git-init-v0.11.2.tar
    docker save entrypoint:v0.11.2 > tekton-pipeline-entrypoint-v0.11.2.tar
    docker save imagedigestexporter:v0.11.2 > tekton-pipeline-imagedigestexporter-v0.11.2.tar
    docker save pullrequest-init:v0.11.2 > tekton-pipeline-pullrequest-init-v0.11.2.tar
    docker save gcs-fetcher:v0.11.2 > tekton-pipeline-gcs-fetcher-v0.11.2.tar
    docker save webhook:v0.11.2 > tekton-pipeline-webhook-v0.11.2.tar
    docker save tianon-true:v0.11.2 > tekton-pipeline-tianon-true-v0.11.2.tar
    docker save busybox:v0.11.2 > tekton-pipeline-busybox-v0.11.2.tar
    docker save google-cloud-sdk:v0.11.2 > tekton-pipeline-google-cloud-sdk-v0.11.2.tar
    ```
    * install yaml을 다운로드한다.
    ```bash
    wget https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.11.2/release.yaml -O tekton-pipeline-v0.11.2.yaml 
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
    docker load < tekton-pipeline-controller-v0.11.2.tar
    docker load < tekton-pipeline-kubeconfigwriter-v0.11.2.tar
    docker load < tekton-pipeline-creds-init-v0.11.2.tar
    docker load < tekton-pipeline-git-init-v0.11.2.tar
    docker load < tekton-pipeline-entrypoint-v0.11.2.tar
    docker load < tekton-pipeline-imagedigestexporter-v0.11.2.tar
    docker load < tekton-pipeline-pullrequest-init-v0.11.2.tar
    docker load < tekton-pipeline-gcs-fetcher-v0.11.2.tar
    docker load < tekton-pipeline-webhook-v0.11.2.tar
    docker load < tekton-pipeline-tianon-true-v0.11.2.tar
    docker load < tekton-pipeline-busybox-v0.11.2.tar
    docker load < tekton-pipeline-google-cloud-sdk-v0.11.2.tar
    
    # Tag images
    docker tag controller:v0.11.2 $REGISTRY/controller:v0.11.2
    docker tag kubeconfigwriter:v0.11.2 $REGISTRY/kubeconfigwriter:v0.11.2
    docker tag creds-init:v0.11.2 $REGISTRY/creds-init:v0.11.2
    docker tag git-init:v0.11.2 $REGISTRY/git-init:v0.11.2
    docker tag entrypoint:v0.11.2 $REGISTRY/entrypoint:v0.11.2
    docker tag imagedigestexporter:v0.11.2 $REGISTRY/imagedigestexporter:v0.11.2
    docker tag pullrequest-init:v0.11.2 $REGISTRY/pullrequest-init:v0.11.2
    docker tag gcs-fetcher:v0.11.2 $REGISTRY/gcs-fetcher:v0.11.2
    docker tag webhook:v0.11.2 $REGISTRY/webhook:v0.11.2
    docker tag tianon-true:v0.11.2 $REGISTRY/tianon-true:v0.11.2
    docker tag busybox:v0.11.2 $REGISTRY/busybox:v0.11.2
    docker tag google-cloud-sdk:v0.11.2 $REGISTRY/google-cloud-sdk:v0.11.2
    
    # Push images
    docker push $REGISTRY/controller:v0.11.2
    docker push $REGISTRY/kubeconfigwriter:v0.11.2
    docker push $REGISTRY/creds-init:v0.11.2
    docker push $REGISTRY/git-init:v0.11.2
    docker push $REGISTRY/entrypoint:v0.11.2
    docker push $REGISTRY/imagedigestexporter:v0.11.2
    docker push $REGISTRY/pullrequest-init:v0.11.2
    docker push $REGISTRY/gcs-fetcher:v0.11.2
    docker push $REGISTRY/webhook:v0.11.2
    docker push $REGISTRY/tianon-true:v0.11.2
    docker push $REGISTRY/busybox:v0.11.2
    docker push $REGISTRY/google-cloud-sdk:v0.11.2
    ```
4. YAML 수정
    ```bash
    REGISTRY=[IP:PORT]
    
    cp tekton-pipeline-v0.11.2.yaml updated.yaml
    sed -i -E "s/gcr.io\/tekton-releases\/.*\/([^@]*)@[^\n\"]*/$REGISTRY\/\1/g" updated.yaml
    sed -i "s/tianon\/true/$REGISTRY\/tianon-true:v0.11.2/g" updated.yaml
    sed -i "s/busybox/$REGISTRY\/busybox:v0.11.2/g" updated.yaml
    sed -i "s/google\/cloud-sdk/$REGISTRY\/google-cloud-sdk:v0.11.2/g" updated.yaml
    ```

## Install Steps
1. [Pipelines 설치](#step-1-pipelines-설치)

## Step 1. Pipelines 설치
* 목적 : `Tekton Pipelines에 필요한 구성 요소 설치`
* 생성 순서 : 아래 command로 설치 yaml 적용
    * (외부망 연결된 환경 설치 시 실행)
    ```bash
    kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.11.2/release.yaml
    ```
    * (폐쇄망 환경 설치 시 실행)
    ```bash
    kubectl apply -f updated.yaml 
    ```
