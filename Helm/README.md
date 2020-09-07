
# Helm 설치 가이드

## 구성 요소 및 버전

## Prerequisites
helm repository server

## 폐쇄망 설치 가이드
설치에 필요한 바이너리를 준비 합니다.

1. Helm 바이너리 파일을 다운받고 설치 합니다.

   - 작업 디렉토리 생성 및 환경 설정

   ```bash
   mkdir -p ~/helm
   export HELM_HOME=~/helm
   cd $HELM_HOME
   ```

   - 외부 네트워크 통신이 가능한 환경에서 필요한 바이너리를 다운로드 받습니다.

   ```bash
   https://github.com/helm/helm/releases 에서 파일을 다운 받습니다.
   ```

2. 폐쇄망으로 파일(.tar)을 옮깁니다.

3. 폐쇄망에서 .tar 압축을 풀고 설치 합니다.

   ```bash
   tar -xvf  helm-{version}-{arch}.tar.gz
   압축풀린 폴더 내부에 진입 합니다.
   helm 바이너리를 /usr/local/bin으로 옮깁니다.
   ```
   - 비고: helm version이 3인 경우는 여기까지만 진행하시면 되고 2인경우에는 이후의 과정도 진행하셔야 합니다.

4. (helm 2.x 만 진행) tiller 계정을 생성 합니다.
   - kubectl apply -f tiller_rbac.yaml ([파일](./yaml_install/tiller_rbac.yaml))

5. (helm 2.x 만 진행) tiller 생성에 필요한 yaml파일을 생성 합니다.
   - helm init --service-account tiller --output yaml >> tiller.yaml

6. (helm 2.x 만 진행) tiller 생성에 필요한 이미지를 다운 받습니다.
    - 외부 네트워크 통신이 가능한 환경에서 윗단계의 결과인 tiller.yaml 내부 image 항목의 주소로 이미지를 다운 받습니다.
    (이미지 항목 주소는 gcr.io/kubernetes-helm/tiller:v{TILLER_VERSION} 이런식으로 되어 있다고 가정 하겠습니다.)
    ```bash
    # Tiller 이미지 Pull
    docker pull gcr.io/kubernetes-helm/tiller:v{TILLER_VERSION} (tiller.yaml파일 참고)

   # 이미지 Save
   docker save gcr.io/kubernetes-helm/tiller:v{TILLER_VERSION} > tiller_v{TILLER_VERSION}.tar
   ```

7. (helm 2.x 만 진행) tiller 이미지파일을 폐쇄망으로 옮긴 후, 폐쇄망에서 사용하는 repository에 이미지를 push 합니다.
   ```bash
   # 이미지 레지스트리 주소
   REGISTRY=[IP:PORT]

   # 이미지 Load
   docker load < tiller_v{TILLER_VERSION}.tar

   # 이미지 Tag
   docker tag gcr.io/kubernetes-helm/tiller:v{TILLER_VERSION} ${REGISTRY}/gcr.io/kubernetes-helm/tiller:v{TILLER_VERSION}

   # 이미지 Push
   docker push ${REGISTRY}/gcr.io/kubernetes-helm/tiller:v{TILLER_VERSION}
   ```

8. (helm 2.x 만 진행) tiller를 생성합니다.
   - tiller.yaml image항목의 주소를 ${REGISTRY}/gcr.io/kubernetes-helm/tiller:v{TILLER_VERSION}로 변경합니다.
   - kubectl apply -f tiller.yaml

9. (helm 2.x 만 진행) helm repository 설정을 합니다.
   - helm init --client-only --stable-repo-url {helm_repo_url}
   - 비고: helm_repo_url은 폐쇄망에서 구축한 helm repository 주소 입니다. (ex.http://192.168.6.76:8080)

## Install Steps
1. [helm 바이너리 다운 및 설치](#Step-1-helm-바이너리-다운-및-설치)
2. [tiller 설치](#Step-2-tiller-생성)

## Step 1. helm 바이너리 다운 및 설치
- 목적 : `helm 바이너리 다운 및 설치`
- 생성 순서 : 
    - https://github.com/helm/helm/releases 에서 바이너리를 다운 받습니다.
    - 해당 파일을 압축 풀고 내부의 helm 바이너리를 옮깁니다.
      ```bash
      tar -xvf  helm-{version}-{arch}.tar.gz
      압축풀린 폴더 내부에 진입 합니다.
      helm 바이너리를 /usr/local/bin으로 옮깁니다.
      ```
## Step 2. tiller 생성 (helm 2.x 만 진행)
- 목적 : `helm client와 kube api server 통신을 위한 tiller 서버를 설치 합니다.`
- 생성 순서 : 
    - tiller 계정을 생성 합니다.
        - kubectl apply -f tiller_rbac.yaml ([파일](./yaml_install/tiller_rbac.yaml))
    - tiller 서버를 생성 합니다.
        - helm init --service-account tiller
- 비고 : Step 2는 helm version이 2인 경우에만 진행 하시면 됩니다. (version 3은 진행할 필요 없음.)