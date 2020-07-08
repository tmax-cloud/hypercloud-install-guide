# Nginx Ingress Controller 설치 가이드

## 구성 요소 및 버전
* nginx-ingress-controller ([quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.33.0](https://quay.io/repository/kubernetes-ingress-controller/nginx-ingress-controller?tab=tags))
* kube-webhook-certgen ([docker.io/jettech/kube-webhook-certgen:v1.2.2](https://hub.docker.com/layers/jettech/kube-webhook-certgen/v1.2.2/images/sha256-4ecb4e11ce3b77a6ca002eeb88d58652d0a199cc802a0aae2128c760300ed4de?context=explore))

## Prerequisites

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. **폐쇄망에서 설치하는 경우** 사용하는 image repository에 istio 설치 시 필요한 이미지를 push한다. 

    * 작업 디렉토리 생성 및 환경 설정
    ```bash
    $ mkdir -p ~/install-ingress-nginx
    $ export NGINX_INGRESS_HOME=~/install-ingress-nginx
    $ export NGINX_INGRESS_VERSION=0.33.0
    $ export KUBE_WEBHOOK_CERTGEN_VERSION=v1.2.2
    $ cd $NGINX_INGRESS_HOME
    ```
    * 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받는다.
    ```bash
    $ sudo docker pull quay.io/kubernetes-ingress-controller/nginx-ingress-controller:${NGINX_INGRESS_VERSION}
    $ sudo docker save quay.io/kubernetes-ingress-controller/nginx-ingress-controller:${NGINX_INGRESS_VERSION} > ingress-nginx_${NGINX_INGRESS_VERSION}.tar
    $ sudo docker pull jettech/kube-webhook-certgen:${KUBE_WEBHOOK_CERTGEN_VERSION}
    $ sudo docker save jettech/kube-webhook-certgen:${KUBE_WEBHOOK_CERTGEN_VERSION} > kube-webhook-certgen_${KUBE_WEBHOOK_CERTGEN_VERSION}.tar
    ```
    * install yaml을 다운로드한다.
    ```bash
    $ wget -O hypercloud-install.tar.gz https://github.com/tmax-cloud/hypercloud-install-guide/archive/v${INSTALL_GUIDE_VERSION}.tar.gz
    ```
  
2. 위의 과정에서 생성한 tar 파일들을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 이미지를 push한다.
    ```bash
    $ sudo docker load < ingress-nginx_${NGINX_INGRESS_VERSION}.tar
    $ sudo docker load < kube-webhook-certgen_${KUBE_WEBHOOK_CERTGEN_VERSION}.tar
    
    $ sudo docker tag quay.io/kubernetes-ingress-controller/nginx-ingress-controller:${NGINX_INGRESS_VERSION} ${REGISTRY}/kubernetes-ingress-controller/nginx-ingress-controller:${NGINX_INGRESS_VERSION}
    $ sudo docker tag jettech/kube-webhook-certgen:${KUBE_WEBHOOK_CERTGEN_VERSION} ${REGISTRY}/istio/proxyv2:${KUBE_WEBHOOK_CERTGEN_VERSION}
    
    $ sudo docker push ${REGISTRY}/kubernetes-ingress-controller/nginx-ingress-controller:${NGINX_INGRESS_VERSION}
    $ sudo docker push ${REGISTRY}/jettech/kube-webhook-certgen:${KUBE_WEBHOOK_CERTGEN_VERSION}
    ```


## Install Steps
0. [deploy yaml 수정](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/IngressNginx#step0-deploy-yaml-%EC%88%98%EC%A0%95)
1. [Nginx Ingress Controller 배포](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/IngressNginx#step-1-nginx-ingress-controller-%EB%B0%B0%ED%8F%AC)


## Step0. deploy yaml 수정
* 목적 : `설치 yaml에 이미지 registry, 버전 정보를 수정`
* 생성 순서 : 
    * 아래의 command를 수정하여 사용하고자 하는 image 버전 정보를 수정한다.
	```bash
	$ sed -i 's/{nginx_ingress_version}/'${NGINX_INGRESS_VERSION}'/g' deploy.yaml
	$ sed -i 's/{kube_webhook_certgen_version}/'${KUBE_WEBHOOK_CERTGEN_VERSION}'/g' deploy.yaml
	```
* 비고 :
    * `폐쇄망에서 설치를 진행하여 별도의 image registry를 사용하는 경우 registry 정보를 추가로 설정해준다.`
	```bash
	$ sed -i 's/quay.io\/kubernetes-ingress-controller\/nginx-ingress-controller/'${REGISTRY}'\/kubernetes-ingress-controller\/nginx-ingress-controller/g' deploy.yaml
	$ sed -i 's/docker.io\/jettech\/kube-webhook-certgen/'${REGISTRY}'\/jettech\/kube-webhook-certgen/g' deploy.yaml
	```

## Step 1. Nginx Ingress Controller 배포
* 목적 : `ingress-nginx system namespace, clusterrole, clusterrolebinding, serviceaccount, deployment 생성`
* 생성 순서 : 
    * [deploy.yaml](yaml/deploy.yaml) 실행 
	```bash
	$ kubectl apply -f deploy.yaml
	```
	* 설치 확인
	```console
	$ kubectl get pods -n ingress-nginx
    NAME                                        READY   STATUS      RESTARTS   AGE
    ingress-nginx-admission-create-jxcjs        0/1     Completed   0          11s
    ingress-nginx-admission-patch-h7kv5         0/1     Completed   0          11s
    ingress-nginx-controller-579fddb54f-xhvmn   1/1     Running     0          11s
    ```


