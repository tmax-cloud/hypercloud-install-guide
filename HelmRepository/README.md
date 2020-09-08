
# Helm Repository 설치 가이드

## 구성 요소 및 버전

## Prerequisites

## 폐쇄망 설치 가이드
설치에 필요한 이미지를 준비합니다.

1. 폐쇄망에서 설치하는 경우 사용하는 image를 다운받고 저장합니다.

   - 작업 디렉토리 생성 및 환경 설정

   ```bash
   mkdir -p ~/helm-repo-install
   export HELM_REPO_HOME=~/helm-repo-install
   cd $HELM_REPO_HOME
   ```

   - 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받습니다.

   ```bash
   # chartmuseum 이미지 Pull
   docker image pull chartmuseum/chartmuseum:latest

   # 이미지 Save
   docker save chartmuseum/chartmuseum:latest > chartmuseum.tar
   ```

2. 폐쇄망으로 파일(.tar)을 옮깁니다.

3. 폐쇄망에서 .tar 압축을 풀고 설치 합니다.

   ```bash
   # 이미지 레지스트리 주소
   REGISTRY=[IP:PORT]

   # 이미지 Load
   docker load < chartmuseum.tar
   # 이미지 Tag
   docker tag chartmuseum/chartmuseum:latest ${REGISTRY}/chartmuseum/chartmuseum:latest

   # 이미지 Push
   docker push ${REGISTRY}/chartmuseum/chartmuseum:latest
   ```

## Install Steps
1. [helm repository 생성](#Step-1-helm-repository-생성)

## Step 1. helm repository 생성
- 목적 : `helm repository 생성`
- 생성 순서 : 아래 command로 yaml 적용
    - kubectl apply -f chartmuseum.yaml ([파일](./yaml_install/chartmuseum.yaml))
- 비고 : 폐쇄망의 경우, yaml파일의 image 항목은 registry주소의 이미지를 사용해야 합니다. (${REGISTRY}/chartmuseum/chartmuseum:latest)
- 비고 : GET서비스를 제외한, 차트를 업로드하거나 삭제하는 서비스는 허가 받은 계정만 사용 가능 합니다. 설정은 chartmuseum.yaml의 BASIC_AUTH_USER(id)/BASIC_AUTH_PASS(password)를 수정 하시면 됩니다.


### chart upload
1. 외부 네트워크 가능한 환경에서 helm chart를 다운 받습니다.
    - helm version 2: helm fetch {repo_name}/{chart_name}
    - helm version 3: helm pull {repo_name}/{chart_name}
2. 다운 받은 chart 혹은 직접 만든 chart (.tgz)파일을 폐쇄망에 구축 되어 있는 helm repository로 업로드 합니다.
    - cd {chart파일이 있는 경로(.tgz)}
    - curl -u {id}:{password} --data-binary "@{file_name}.tgz" http://{repo_ip}:{repo_port}/api/charts
    - 비고: repo_ip 및 port는 step 1에서 생성한 service의 loadbalancer ip 및 port 이며, id 및 password는 chartmuseum.yaml에 설정되어 있는 BASIC_AUTH_USER와 BASIC_AUTH_PASS를 의미 합니다.
3. 업로드 확인
    - curl http://{repo_ip}:{repo_port}/api/charts
4. 기타 API 사용법은 https://github.com/helm/chartmuseum 를 참조하시면 됩니다.

### chart delete
1. curl -u {id}:{password} -X DELETE http://{repo_ip}:{repo_port}/api/charts/{chart_name}/{chart_version}
    - 비고 : repo_ip 및 port는 step 1에서 생성한 service의 loadbalancer ip 및 port 이며, id 및 password는 chartmuseum.yaml에 설정되어 있는 BASIC_AUTH_USER와 BASIC_AUTH_PASS를 의미 합니다.