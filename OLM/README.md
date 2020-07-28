# Operator Lifecycle Manager 설치 가이드

## 구성 요소 및 버전
* OLM: ([quay.io/operator-framework/olm:0.15.1](https://quay.io/repository/operator-framework/olm/manifest/sha256:2c389d2e380c842cbf542820ad4493249164302ddf0e699b0a37105d234e67ee))
* Operator Registry: ([quay.io/operator-framework/configmap-operator-registry:v1.13.3](https://quay.io/repository/operator-framework/configmap-operator-registry/manifest/sha256:e8458dbd7cc7650f0e84bb55cb1f9f30937dd0b010377634ea75f6d9a4f6ee85))

## Prerequisites
* git
* go version v1.12+.
* docker version 17.03+.
  * Alternatively podman v1.2.0+ or buildah v1.7+
* kubectl version v1.11.3+.
* Access to a Kubernetes v1.11.3+ cluster.

## 폐쇄망 설치 가이드
    

## Install Steps
0. [olm yaml 수정](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/HyperCloud%20Webhook#step-0-hypercloud-webhook-yaml-%EC%88%98%EC%A0%95)
1. [crds 생성](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/HyperCloud%20Webhook#step-1-%EC%9D%B8%EC%A6%9D%EC%84%9C-%EC%83%9D%EC%84%B1)
2. [OLM 설치](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/HyperCloud%20Webhook#step-2-secret-%EC%83%9D%EC%84%B1)

## Step 0. olm yaml 수정 수정
* 목적 : `olm yaml에 이미지 버전 정보를 수정`
* 생성 순서 : 아래의 command를 실행하여 사용하고자 하는 image 버전을 수정한다. ([02_olm.yaml](yaml/02_olm.yaml))
    ```bash
    $ sed -i 's/{olm_version}/'${OLM_VERSION}'/g' 02_olm.yaml
    $ sed -i 's/{registry_version}/'${REGISTRY_VERSION}'/g' 02_olm.yaml
    ```

## Step 1. CRDs 생성
* 목적 : `OLM 설치를 위해 필요한 Custorm Resource를 정의한다.`
* 생성 순서 : [01_crds.yaml](yaml/01_crds.yaml) 실행 `ex) kubectl apply -f 01_crds.yaml`

## Step 2. OLM 설치
* 목적 : `OLM 동작을 위해 필요한 리소스 (namespace, clusterrole, deployment 등)를 생성한다.`
* 생성 순서 : [02_olm.yaml](yaml/02_olm.yaml) 실행 `ex) kubectl apply -f 02_olm.yaml`
