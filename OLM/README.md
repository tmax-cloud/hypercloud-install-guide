# Operator Lifecycle Manager 설치 가이드

## 구성 요소 및 버전
* OLM: ([quay.io/operator-framework/olm:0.15.1](https://quay.io/repository/operator-framework/olm/manifest/sha256:2c389d2e380c842cbf542820ad4493249164302ddf0e699b0a37105d234e67ee))
* Registry Configmap: ([quay.io/operator-framework/configmap-operator-registry:v1.13.3](https://quay.io/repository/operator-framework/configmap-operator-registry/manifest/sha256:e8458dbd7cc7650f0e84bb55cb1f9f30937dd0b010377634ea75f6d9a4f6ee85))
* Catalog Registry ([quay.io/operator-framework/upstream-community-operators:latest](https://quay.io/repository/operator-framework/upstream-community-operators/manifest/sha256:abaa54d83d2825c7d2bc9367edbc1a3707df88e43ded36ff441398f23f030b6e))

## Prerequisites
* git
* go version v1.12+.
* docker version 17.03+.
  * Alternatively podman v1.2.0+ or buildah v1.7+
* kubectl version v1.11.3+.
* Access to a Kubernetes v1.11.3+ cluster.

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. **폐쇄망에서 설치하는 경우** 사용하는 image repository에 HyperCloud Webhook 설치 시 필요한 이미지를 push한다. 

    * 작업 디렉토리 생성 및 환경 설정
    ```bash
    $ mkdir -p ~/olm-install
    $ export OLM_HOME=~/olm-install
    $ export OLM_VERSION=0.15.1
    $ export CFM_VERSION=v1.13.3
    $ export REG_VERSION=latest
    $ cd $OLM_HOME
    ```
    * 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받는다.
    ```bash
    $ sudo docker pull quay.io/operator-framework/olm:${OLM_VERSION}
    $ sudo docker save quay.io/operator-framework/olm:${OLM_VERSION} > olm_${OLM_VERSION}.tar
    $ sudo docker pull quay.io/operator-framework/configmap-operator-registry:${CFM_VERSION}
    $ sudo docker save quay.io/operator-framework/configmap-operator-registry:${CFM_VERSION} > configmap_${CFM_VERSION}.tar
    $ sudo docker pull quay.io/operator-framework/upstream-community-operators:${REG_VERSION}
    $ sudo docker save quay.io/operator-framework/upstream-community-operators:${REG_VERSION} > registry_${REG_VERSION}.tar    
    ```
    * install yaml을 다운로드한다.
    ```bash
    $ git clone https://github.com/tmax-cloud/hypercloud-install-guide.git
    $ cd olm-install/OLM/yaml
    ```
  
2. 위의 과정에서 생성한 tar 파일들을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 이미지를 push한다.
    ```bash
    $ sudo docker load < olm_${OLM_VERSION}.tar
    
    $ sudo docker tag quay.io/operator-framework/olm:${OLM_VERSION} ${REGISTRY}/operator-framework/olm:${OLM_VERSION}
    
    $ sudo docker push ${REGISTRY}/operator-framework/olm:${OLM_VERSION}
    
    $ sudo docker load < configmap_${CFM_VERSION}.tar
    
    $ sudo docker tag quay.io/operator-framework/configmap-operator-registry:${CFM_VERSION} ${REGISTRY}/operator-framework/configmap-operator-registry:${CFM_VERSION}
    
    $ sudo docker push ${REGISTRY}/operator-framework/configmap-operator-registry:${CFM_VERSION}
    
    $ sudo docker tag quay.io/operator-framework/upstream-community-operators:${REG_VERSION} ${REGISTRY}/operator-framework/upstream-community-operators:${REG_VERSION}
    
    $ sudo docker push ${REGISTRY}/operator-framework/upstream-community-operators:${REG_VERSION}
    ```
    
3. 설치할 Operator 이미지를 폐쇄망에서 다운받기 위해 Custom Registry를 빌드한다. (e.g. Prometheus Operator 0.22) 
    ```bash
    $ cd private
    
    $ cp bin/* /bin/
    
    $ sed -i 's/{registry}/'${REGISTRY}'/g' catalog_build.sh
    
    $ sed -i 's/{registry}/'${REGISTRY}'/g' prom_0.22/prometheusoperator.0.22.2.clusterserviceversion.yaml
    
    $ sh catalog_build.sh
    ```
    
4. Custom Registry를 폐쇄망 환경에 구성한다.
    ```bash
    $ sed -i 's/{registry}/'${REGISTRY}'/g' custom_catalogsource.yaml
    
    $ kubectl apply -f custom_catalogsource.yaml
    ```

## Install Steps
0. [olm yaml 수정](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/HyperCloud%20Webhook#step-0-hypercloud-webhook-yaml-%EC%88%98%EC%A0%95)
1. [crds 생성](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/HyperCloud%20Webhook#step-1-%EC%9D%B8%EC%A6%9D%EC%84%9C-%EC%83%9D%EC%84%B1)
2. [OLM 설치](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/HyperCloud%20Webhook#step-2-secret-%EC%83%9D%EC%84%B1)

## Step 0. olm yaml 수정 수정
* 목적 : `olm yaml에 이미지 버전 정보를 수정`
* 생성 순서 : 아래의 command를 실행하여 사용하고자 하는 image 버전을 수정한다. ([02_olm.yaml](yaml/02_olm.yaml))
    ```bash
    $ sed -i 's/{olm_version}/'${OLM_VERSION}'/g' 02_olm.yaml
    $ sed -i 's/{configmap_version}/'${CFM_VERSION}'/g' 02_olm.yaml
    $ sed -i 's/{registry_version}/'${REG_VERSION}'/g' 02_olm.yaml
    ```
    
* 비고 :
    * 폐쇄망에서 설치를 진행하여 별도의 image registry를 사용하는 경우 registry 정보를 추가로 설정해준다.
	```bash
	$ sed -i 's/quay.io\operator-framework/'${REGISTRY}'\/operator-framework/g' 02_olm.yaml
	```


## Step 1. CRDs 생성
* 목적 : `OLM 설치를 위해 필요한 Custorm Resource를 정의한다.`
* 생성 순서 : [01_crds.yaml](yaml/01_crds.yaml) 실행 `ex) kubectl apply -f 01_crds.yaml`



## Step 2. OLM 설치
* 목적 : `OLM 동작을 위해 필요한 리소스 (namespace, clusterrole, deployment 등)를 생성한다.`
* 생성 순서
  * [02_olm.yaml](yaml/02_olm.yaml) 실행 `ex) kubectl apply -f 02_olm.yaml`
  
  * 아래의 명령어를 사용하여 OLM이 정상적으로 설치되었는지 확인한다.
  ```bash
    $ kubectl get pods -n olm
    $ kubectl get catalogsource -n olm
   ```
  ![image](figure/olm_pods.png)
  ![image](figure/olm_catalogsource.png)
