
# NetworkAgent 설치 가이드

## 구성 요소 및 버전
* Network Agent([tmaxcloudck/hypernet-local-agent:v0.4.2](https://hub.docker.com/repository/docker/tmaxcloudck/hypernet-local-agent))

## Prerequisites
1. Kubernetest ( 1.15.0 <= )
2. Calico ( 3.13.4 <= )
    * Agent가 동작하기 위해선 Calico CNI가 설치 되어 있어야합니다.
    * 현재 Calico 이외의 CNI는 지원하지 않습니다.
3. Calicoctl ( 3.15.0 <= )

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. **폐쇄망에서 설치하는 경우** 사용하는 image repository에 Agent 설치 시 필요한 이미지를 push한다.     
    * 작업 디렉토리 생성 및 환경 설정
    ```bash
    $ export HYPERNET_LOCAL_AGENT_VERSION=0.4.2
    ```

    * 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받는다.
    ```bash
    $ sudo docker pull tmaxcloudck/hypernet-local-agent:${HYPERNET_LOCAL_AGENT_VERSION}
    $ sudo docker save tmaxcloudck/hypernet-local-agent:${HYPERNET_LOCAL_AGENT_VERSION} > tmaxcloudck_hypernet-local-agent_${HYPERNET_LOCAL_AGENT_VERSION}.tar
    ```

2. 위의 과정에서 생성한 tar 파일들을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 이미지를 push한다.
    ```bash
    $ sudo docker load < tmaxcloudck_hypernet-local-agent_${HYPERNET_LOCAL_AGENT_VERSION}.tar
    $ sudo docker tag tmaxcloudck/hypernet-local-agent:${HYPERNET_LOCAL_AGENT_VERSION} ${REGISTRY}/tmaxcloudck/hypernet-local-agent:${HYPERNET_LOCAL_AGENT_VERSION}   
    $ sudo docker push ${REGISTRY}/tmaxcloudck/hypernet-local-agent:${HYPERNET_LOCAL_AGENT_VERSION}  
    ```
    
## Install Steps
0. [Static IP 사용을 위한 IPPool 설정](#step0 "step0")
1. [Floating IP 사용을 위한 IPPool 설정](#step1 "step1")
2. [Hypernet-Local-Agent 설치](#step2 "step2")

<h2 id="step0">
Step 0. IPPool 설정(Static IP 전용. Static IP를 사용하지 않을 경우 Skip)
</h2>

* 목적 : `Static IP 사용을 위한 Public 대역 IP Pool 설정`
* 생성 순서 : 
    * Default IPPool 설정
            * 기존 Calico 설치 이후 default IP Pool로 설정되어 있는 IP Pool의 NatOutgoing flag 변경
            * default-ipv4-ippool.yaml의 cidr 부분을 자신의 환경에 맞게 변경하고 natOutgoing 값이 false인지 확인
	    * default-ipv4-ippool.yaml의 내용을 아래 커맨드를 통해 Calico에 적용
	    ```bash
	        cat default-ipv4-ippool.yaml | calicoctl replace -f -
	    ```
    * Public IP Pool 설정 
	    * Static IP를 사용하기 위해 Public IP Pool을 생성해야함
	    * CIDR를 원하는 public ip 대역으로 설정해야함 (메탈엘비 대역이랑 겹치면 문제 발생)
		    * ex) 172.22.8.180, 172.22.8.181 => 172.22.8.180/31
		    * ex) 172.22.8.180, 181, 182, 183 => 172.22.8.180/30
		    * [주의] 호스트 대역이랑 겹치면 통신이 끊길 수 있음
		    * 대역에 관해서 문의해주시면 확인해드립니다
            * public-ipv4-ippool.yaml의 cidr 부분을 자신이 사용하려는 대역에 맞게 설정
	    * public-ipv4-ippool.yaml의 내용을 아래 커맨드를 통해 Calico에 적용
	    ```bash
	        cat public-ipv4-ippool.yaml | calicoctl create -f -
	    ```


<h2 id="step1">
Step 1. IPPool 설정(Floating IP 전용. Floating IP를 사용하지 않을 경우 Skip)
</h2>

* 목적 : `Floating IP 사용을 위한 Public 대역 IP Pool 설정`
* 생성 순서 : 
    * ConfigMap 생성
            * 사용하려는 Floating IP들을 configMap으로 정의
            * floatingIp.yaml 의 NatIpList 에 사용할 private IP 기입 (default-ipv4-ippool에 있는 ip중에 임의로 미리 정함)
	    * floatingIp.yaml의 NatIpList부분 수정
            * floatingIp.yaml의 내용을 아래 커맨드를 통해 K8S에 적용
	    ```bash
	        kubectl apply floatingIp.yaml
	    ```
	    
<h2 id="step2">
Step 2. Hypernet-Local-Agent 설치
</h2>

* 목적 : `Hypernet-Local-Agent 설치`
* 생성 순서 : 
    *  hypernet-local-agent.yaml 설정
            * `ex) kubectl apply -f hypernet-local-agent.yaml`
            * Pod들이 사용하는 IP 대역의 Pool 이름 확인
	    ```bash
	    	kubectl get ippool
	    ```
            * 만약 Pod가 사용하는 IP Pool의 이름이 "default-ipv4-ippool"이 아니라면 Hypernet-Local-Agent.yaml에 환경변수("POD_IPPOOL_NAME")로 넣어주어야함
    * Hypernet-Local-Agent 설치
	    ```bash
	        kubectl apply hypernet-local-agent.yaml
	    ```
	



