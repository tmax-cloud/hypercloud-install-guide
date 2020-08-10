

# hypercloud-operator 설치 가이드

## 구성 요소
* hypercloud-operator
	* image: [https://hub.docker.com/r/tmaxcloudck/hypercloud-operator/tags](https://hub.docker.com/r/tmaxcloudck/hypercloud-operator/tags)
	* git: [https://github.com/tmax-cloud/hypercloud-operator](https://github.com/tmax-cloud/hypercloud-operator)

## Prerequisite
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. **폐쇄망에서 설치하는 경우** 사용하는 image repository에 필요한 이미지를 push한다. 

    * 작업 디렉토리 생성 및 환경 설정
    ```bash
	$ mkdir -p ~/hypercloud-operator-install
	$ export HPCD_HOME=~/hypercloud-operator-install
	$ export HPCD_VERSION=<tag1>
	$ cd ${HPCD_HOME}

	* <tag1>에는 설치할 hypercloud-operator 버전 명시
		예시: $ export HPCD_VERSION=4.1.0.41
    ```
    * 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받는다.
    ```bash
	# mysql
	$ sudo docker pull mysql:5.6
	$ sudo docker save mysql:5.6 > mysql_5.6.tar

	# registry: hypercloud에서 private registry 생성 서비스 사용시 필요
	$ sudo docker pull registry:2.6.2
	$ sudo docker save registry:2.6.2 > registry_2.6.2.tar

	# hypercloud-operator
	$ sudo docker pull tmaxcloudck/hypercloud-operator:b${HPCD_VERSION}
	$ sudo docker save tmaxcloudck/hypercloud-operator:b${HPCD_VERSION} > hypercloud-operator_b${HPCD_VERSION}.tar
    ```
    * install yaml을 다운로드한다.
    ```bash
    $ wget -O hypercloud-operator.tar.gz https://github.com/tmax-cloud/hypercloud-operator/archive/v${HPCD_VERSION}.tar.gz
    ```
  
2. 위의 과정에서 생성한 tar 파일들을 `폐쇄망 환경으로 이동`시킨 뒤 사용하려는 registry에 이미지를 push한다.
	* 작업 디렉토리 생성 및 환경 설정
    ```bash
	$ mkdir -p ~/hypercloud-operator-install
	$ export HPCD_HOME=~/hypercloud-operator-install
	$ export HPCD_VERSION=<tag1>
	$ export REGISTRY=<REGISTRY_IP_PORT>
	$ cd ${HPCD_HOME}

	* <tag1>에는 설치할 hypercloud-operator 버전 명시
		예시: $ export HPCD_VERSION=4.1.0.41
	* <REGISTRY_IP_PORT>에는 폐쇄망 Docker Registry IP:PORT명시
		예시: $ export REGISTRY=192.168.6.110:5000
	```
    * 이미지 load 및 push
    ```bash
    # Load Images
    $ sudo docker load < mysql_5.6.tar
	$ sudo docker load < registry_2.6.2.tar
	$ sudo docker load < hypercloud-operator_b${HPCD_VERSION}.tar
    
    # Change Image's Tag For Private Registry
    $ sudo docker tag mysql:5.6 ${REGISTRY}/mysql:5.6
	$ sudo docker tag registry:2.6.2 ${REGISTRY}/registry:2.6.2
	$ sudo docker tag tmaxcloudck/hypercloud-operator:b${HPCD_VERSION} ${REGISTRY}/tmaxcloudck/hypercloud-operator:b${HPCD_VERSION}
    
    # Push Images
    $ sudo docker push ${REGISTRY}/mysql:5.6
	$ sudo docker push ${REGISTRY}/registry:2.6.2
	$ sudo docker push ${REGISTRY}/tmaxcloudck/hypercloud-operator:b${HPCD_VERSION}
    ```


## Install Steps
1. [1.initialization.yaml 실행](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/HyperCloud%20Operator/README.md#step-1-1initializationyaml-%EC%8B%A4%ED%96%89)
2. [CRD 적용](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/HyperCloud%20Operator/README.md#step-2-crd-%EC%A0%81%EC%9A%A9)
3. [2.mysql-settings.yaml 실행](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/HyperCloud%20Operator/README.md#step-3-2mysql-settingsyaml-%EC%8B%A4%ED%96%89)
4. [3.mysql-create.yaml 실행](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/HyperCloud%20Operator/README.md#step-4-3mysql-createyaml-%EC%8B%A4%ED%96%89)
5. [6.hypercloud4-operator.yaml 실행](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/HyperCloud%20Operator/README.md#step-5-6hypercloud4-operatoryaml-%EC%8B%A4%ED%96%89)
6. [8.default-auth-object-init.yaml 실행](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/HyperCloud%20Operator/README.md#step-6-8default-auth-object-inityaml-%EC%8B%A4%ED%96%89)
7. [webhook-config 설정](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/HyperCloud%20Operator/README.md#step-7-webhook-config-%EC%84%A4%EC%A0%95)


## Step 0. install  yaml 수정
* 목적 : `hypercloud-operator install yaml파일 내용 수정`
* 실행 순서: 
	* 이미지 주소 수정
		```bash
		$ cd ${HPCD_HOME}
		$ tar -xvzf hypercloud-operator.tar.gz

		$ sed -i 's/mysql:5.6/'${REGISTRY}'\/mysql:5.6/g' ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_Install/3.mysql-create.yaml
		$ sed -i 's/tmaxcloudck\/hypercloud-operator/'${REGISTRY}'\/tmaxcloudck\/hypercloud-operator/g' ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_Install/6.hypercloud4-operator.yaml

		$ sed -i 's/{HPCD_VERSION}/'${HPCD_VERSION}'/g' ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_Install/6.hypercloud4-operator.yaml
		```


## Step 1. 1.initialization.yaml 실행
* 목적 : `hypercloud4-system namespace, resourcequota, clusterrole, clusterrolebinding, serviceaccount, configmap 생성`
* 실행 순서: 
	```bash
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_Install/1.initialization.yaml
	```

## Step 2. CRD 적용
* 목적 : `hypercloud crd 생성`
* 실행 : *CRD.yaml실행
	```bash
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_CRD/${HPCD_VERSION}/Auth/UserCRD.yaml
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_CRD/${HPCD_VERSION}/Auth/UsergroupCRD.yaml
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_CRD/${HPCD_VERSION}/Auth/TokenCRD.yaml
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_CRD/${HPCD_VERSION}/Auth/ClientCRD.yaml
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_CRD/${HPCD_VERSION}/Auth/UserSecurityPolicyCRD.yaml
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_CRD/${HPCD_VERSION}/Claim/NamespaceClaimCRD.yaml
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_CRD/${HPCD_VERSION}/Claim/ResourceQuotaClaimCRD.yaml
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_CRD/${HPCD_VERSION}/Claim/RoleBindingClaimCRD.yaml
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_CRD/${HPCD_VERSION}/Registry/RegistryCRD.yaml
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_CRD/${HPCD_VERSION}/Registry/ImageCRD.yaml
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_CRD/${HPCD_VERSION}/Template/TemplateCRD_v1beta1.yaml
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_CRD/${HPCD_VERSION}/Template/TemplateInstanceCRD_v1beta1.yaml
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_CRD/${HPCD_VERSION}/Template/CatalogServiceClaimCRD_v1beta1.yaml
	```


## Step 3. 2.mysql-settings.yaml 실행
* 목적 : `mysql secret, configmap 생성`
* 실행: 
	```bash
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_Install/2.mysql-settings.yaml
	```


## Step 4. 3.mysql-create.yaml 실행
* 목적 : `mysql pvc, deployment, svc 생성`
* 실행: 
	```bash
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_Install/3.mysql-create.yaml
	```


## Step 5. 6.hypercloud4-operator.yaml 실행
* 목적: `hypercloud-operator deployment, svc 생성`
* 준비: 
	* 폐쇄망의 경우
		* 6.hypercloud4-operator.yaml 내용 수정
			* spec.template.spec.containers.env.name: PROAUTH_EXIST**의 value를 “0”으로 수정**
			```bash								 
			$ vi ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_Install/6.hypercloud4-operator.yaml
			```
		* Example
			* spec.template.spec.containers.env.value: “0” <-- PROAUTH_EXIST의 value
			
* 실행: 
	```bash
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_Install/6.hypercloud4-operator.yaml
	```


## Step 6. 8.default-auth-object-init.yaml 실행
* 목적 : `defulat User 생성`
* 실행: 
	```bash
	$ kubectl apply -f ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_Install/8.default-auth-object-init.yaml
	```


## Step 7. webhook-config 설정
* 목적 : `webhook-config 설정`
* 실행: 
	```bash
	# HYPERCLOUD_IP 알맞게 변경
	$ vi ${HPCD_HOME}/hypercloud-operator-${HPCD_VERSION}/_yaml_Install/webhook-config
	```
* 비고 : 
    * /etc/kubernetes/pki directory 에 webhook-config 파일 복사
	* kube api-server manifest 설정 추가 : --authentication-token-webhook-config-file=/etc/kubernetes/pki/webhook-config
