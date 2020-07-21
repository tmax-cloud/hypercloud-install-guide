
# Network Webhook 설치 가이드

## 구성 요소 및 버전
* Network Webhook([tmaxcloudck/network-hook:v0.1.1](https://hub.docker.com/repository/docker/tmaxcloudck/network-hook))

## Prerequisites
1. Hypernet-Local-Agent
    * Network Webhook이 hypernet-local-agent-system namespace에서 동작하기 위해, hypernet-local-agent 설치가 선행되어야 합니다.

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. **폐쇄망에서 설치하는 경우** 사용하는 image repository에 Agent 설치 시 필요한 이미지를 push한다.     
    * 작업 디렉토리 생성 및 환경 설정
    ```bash
    $ export NETWORK_HOOK_VERSION=0.1.1
    ```

    * 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받는다.
    ```bash
    $ sudo docker pull tmaxcloudck/network-hook:${NETWORK_HOOK_VERSION}
    $ sudo docker save tmaxcloudck/network-hook:${NETWORK_HOOK_VERSION} > network-hook_${NETWORK_HOOK_VERSION}.tar
    ```

2. 위의 과정에서 생성한 tar 파일들을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 이미지를 push한다.
    ```bash
    $ sudo docker load < network-hook_${NETWORK_HOOK_VERSION}.tar
    $ sudo docker tag tmaxcloudck/network-hook:${NETWORK_HOOK_VERSION} ${REGISTRY}/tmaxcloudck/network-hook:${NETWORK_HOOK_VERSION}   
    $ sudo docker push ${REGISTRY}/tmaxcloudck/network-hook:${NETWORK_HOOK_VERSION}  
    ```
    
## Install Steps
1. [TLS 통신을 위한 Certificate와 Key 생성](#step1 "step1")
2. [Network-hook 설치](#step2 "step2")

<h2 id="step1">
Step 1. TLS 통신을 위한 Certificate와 key 생성
</h2>

* 목적 : `TLS 통신을 위한 Certificate와 key 생성 및 network-hook.yaml에 해당 정보 반영`
* 생성 순서 : 
    * CSR 인증 및 cert/key secret으로 생성
            * Webhook Server 와 API Server간 TLS 통신을 위해 Kubernetes CSR을 이용하여 Cert와 Key 생성
            * Cert와 key를 secret으로 생성
            * network-hook.yaml의 <CA_BUNDLE> 값을 자동으로 반영
	    * 아래 스크립트를 실행하여 적용
            * network-hook.yaml이 patch.sh와 반드시 같은 디렉토리에 있어야함!
	    ```bash
	        ./patch.sh
	    ```
	    
<h2 id="step2">
Step 2. Network-hook 설치
</h2>

* 목적 : `Network-hook 설치`
* 생성 순서 : 
    * Network-hook 설치
        * 
	    ```bash
	        kubectl apply -f network-hook.yaml
	    ```