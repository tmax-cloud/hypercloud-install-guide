# TemplateServiceBroker 설치 가이드

## 구성 요소 및 버전

- template-service-broker ([tmaxcloudck/template-service-broker:b4.0.0.4](https://hub.docker.com/layers/tmaxcloudck/template-service-broker/b4.0.0.4/images/sha256-d0dbd995667f5ba35dd85d568fb7cc776d6b1ddd7cbca3a6849d8d74c67817f9?context=explore))

## Prerequisites

TemplateServiceBroker 설치 전, Hypercloud operator 및 catalog controller module이 설치 되어 있어야 합니다.

설치에 필요한 이미지를 준비합니다.

1. 폐쇄망에서 설치하는 경우 사용하는 image를 다운받고 저장합니다.

   - 작업 디렉토리 생성 및 환경 설정

   ```bash
   mkdir -p ~/template-service-broker-install
   export TSB_HOME=~/template-service-broker-install
   export TSB_VERSION=4.0.0.5
   cd $TSB_HOME
   ```

   - 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받습니다.

   ```bash
   # TEMPLATE SERVICE BROKER 이미지 Pull
   docker pull tmaxcloudck/template-service-broker:b${TSB_VERSION}

   # 이미지 Save
   docker save tmaxcloudck/template-service-broker:b${TSB_VERSION} > template-service-broker_b${TSB_VERSION}.tar
   ```

2. 폐쇄망으로 이미지 파일(.tar)을 옮깁니다.

3. 폐쇄망에서 사용하는 image repository에 이미지를 push 합니다.

   ```bash
   # 이미지 레지스트리 주소
   REGISTRY=[IP:PORT]

   # 이미지 Load
   docker load < template-service-broker_b${TSB_VERSION}.tar

   # 이미지 Tag
   docker tag tmaxcloudck/template-service-broker:b${TSB_VERSION} ${REGISTRY}/tmaxcloudck/template-service-broker:b${TSB_VERSION}

   # 이미지 Push
   docker push ${REGISTRY}/tmaxcloudck/template-service-broker:b${TSB_VERSION}
   ```

## Install Steps

1. [TemplateServiceBroker Namespace 및 ServiceAccount 생성](#Step-1-TemplateServiceBroker-Namespace-및-ServiceAccount-생성)
2. [Role 및 RoleBinding 생성](#Step-2-Role-및-RoleBinding-생성)
3. [TemplateServiceBroker 생성](#Step-3-TemplateServiceBroker-Server-생성)
4. [TemplateServiceBroker Service 생성](#Step-4-TemplateServiceBroker-Service-생성)
5. [TemplateServiceBroker 등록](#Step-5-TemplateServiceBroker-등록)

## Step 1. TemplateServiceBroker Namespace 및 ServiceAccount 생성

- 목적 : `TemplateServiceBroker Namespace 및 ServiceAccount 생성.`
- 생성 순서 : 아래 command로 yaml 적용
  - (namespace:tsb-ns / serviceaccount: tsb-account라고 가정)
  - kubectl create namespace tsb-ns
  - kubectl apply -f tsb_serviceaccount.yaml ([파일](./yaml_install/tsb_serviceaccount.yaml))
- 비고 : namespace, serviceaccount 변경 시, step1 이후 단계의 namesapce 및 serviceaccount 도 모두 맞게 변경해야 합니다.

## Step 2. Role 및 RoleBinding 생성

- 목적 : `해당 namespace의 serviceaccount에 권한 부여.`
- 생성 순서 : 아래 command로 yaml 적용
  - (namespace:tsb-ns / serviceaccount: tsb-account / ${USER_ID}:hypercloud 계정 id 라고 가정)
  - kubectl apply -f tsb_role.yaml ([파일](./yaml_install/tsb_role.yaml))
  - kubectl apply -f tsb_cluster_role.yaml ([파일](./yaml_install/tsb_cluster_role.yaml))
  - kubectl apply -f tsb_rolebinding.yaml ([파일](./yaml_install/tsb_rolebinding.yaml))
  - kubectl apply -f tsb_cluster_rolebinding.yaml ([파일](./yaml_install/tsb_cluster_rolebinding.yaml))
- 비고 : rolebinding, clusterRolebinding 의 ${USER_ID}를 사용자 계정 id로 변경해주셔야 합니다.

## Step 3. TemplateServiceBroker Server 생성

- 목적 : `TemplateServiceBroker Server deploy 및 서비스 계정 마운트.`
- 생성 순서 : 아래 commmand로 yaml 적용
  - (namespace:tsb-ns / serviceaccount: tsb-account라고 가정)
  - kubectl apply -f tsb_deployment.yaml ([파일](./yaml_install/tsb_deployment.yaml))
- 비고 : 폐쇄망의 경우, yaml파일의 image 항목은 registry주소의 이미지를 사용해야 합니다. (${REGISTRY}/tmaxcloudck/template-service-broker:b${TSB_VERSION})

## Step 4. TemplateServiceBroker Service 생성

- 목적 : `server에 접속하기 위한 endpoint 생성.`
- 생성 순서 : 아래 commmand로 yaml 적용
  - (namespace:tsb-ns / serviceaccount: tsb-account라고 가정)
  - kubectl apply -f tsb_service.yaml ([파일](./yaml_install/tsb_service.yaml))

## Step 5. TemplateServiceBroker 등록

- 목적 : `TemplateServiceBroker 등록.`
- 생성 순서 : 아래 commmand로 yaml 적용
  - (namespace:tsb-ns / serviceaccount: tsb-account라고 가정)
  - kubectl apply -f tsb_service_broker.yaml ([파일](./yaml_install/tsb_service_broker.yaml))
- 비고 : yaml파일의 {SERVER_IP}는 Step 4. Service를 통해 생성된 EXTERNAL-IP로 수정해야 합니다.
