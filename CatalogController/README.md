
# CatalogContoller 설치 가이드

## 구성 요소 및 버전

## Prerequisites
- helm version 2

## 폐쇄망 설치 가이드
설치에 필요한 이미지를 준비합니다.

1. 폐쇄망에서 설치하는 경우 사용하는 image를 다운받고 저장합니다.

   - 작업 디렉토리 생성 및 환경 설정

   ```bash
   mkdir -p ~/catalog-controller-install
   export CATALOG_HOME=~/catalog-controller-install
   export CATALOG_VERSION=0.3.0
   cd $CATALOG_HOME
   ```

   - 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받습니다.

   ```bash
   # TEMPLATE SERVICE BROKER 이미지 Pull
   docker pull quay.io/kubernetes-service-catalog/service-catalog:v${CATALOG_VERSION}

   # 이미지 Save
   docker save quay.io/kubernetes-service-catalog/service-catalog:v${CATALOG_VERSION} > service-catalog_v${TSB_VERSION}.tar
   ```

2. 폐쇄망으로 이미지 파일(.tar)을 옮깁니다.

3. 폐쇄망에서 사용하는 image repository에 이미지를 push 합니다.

   ```bash
   # 이미지 레지스트리 주소
   REGISTRY=[IP:PORT]

   # 이미지 Load
   docker load < service-catalog_v${TSB_VERSION}.tar

   # 이미지 Tag
   docker tag quay.io/kubernetes-service-catalog/service-catalog:v${CATALOG_VERSION} ${REGISTRY}/quay.io/kubernetes-service-catalog/service-catalog:v${CATALOG_VERSION}

   # 이미지 Push
   docker push ${REGISTRY}/quay.io/kubernetes-service-catalog/service-catalog:v${CATALOG_VERSION}
   ```
4. 설치에 필요한 crd를 생성 합니다.
- kubectl apply -f crds/ ([폴더](./yaml_install/crds))

5. 설치에 필요한 yaml을 적용 합니다.
- kubectl apply -f cleaner-job.yaml ([파일](./yaml_install/cleaner-job.yaml))
- kubectl apply -f controller-manager-deployment.yaml ([파일](./yaml_install/controller-manager-deployment.yaml))
- kubectl apply -f controller-manager-service.yaml ([파일](./yaml_install/controller-manager-service.yaml))
- kubectl apply -f migration-job ([파일](./yaml_install/migration-job.yaml))
- kubectl apply -f pre-migration-job.yaml ([파일](./yaml_install/pre-migration-job.yaml))
- kubectl apply -f rbac.yaml ([파일](./yaml_install/rbac.yaml))
- kubectl apply -f serviceaccounts.yaml ([파일](./yaml_install/serviceaccounts.yaml))
- kubectl apply -f webhook-deployment.yaml ([파일](./yaml_install/webhook-deployment.yaml))
- kubectl apply -f webhook-register.yaml ([파일](./yaml_install/webhook-register.yaml))
- kubectl apply -f webhook-service.yaml ([파일](./yaml_install/webhook-service.yaml))
- 비고: 각 파일에 image 항목이 있는 경우, registry주소의 이미지를 사용해야 합니다. (${REGISTRY}/quay.io/kubernetes-service-catalog/service-catalog:v${CATALOG_VERSION})

## Install Steps
1. [helm을 통한 CatalogController 설치](Step-1-helm을-통한-CatalogController-설치)

## Step 1. helm을 통한 CatalogController 설치
- 목적 : `CatalogController 설치`
- 생성 순서 : 
    - CatalogController 차트 저장소를 로컬 저장소에 추가 합니다.
      ```bash
      helm repo add svc-cat https://svc-catalog-charts.storage.googleapis.com
      ```

    - 지정된 버전으로 CatalogController chart 설치 합니다.
      ```bash
      helm search service-catalog
      helm install svc-cat/catalog --name catalog --version=<x.x.x> --namespace catalog
      ```
