# K8S Master 클러스터의 LBNode 설치 가이드(HAProxy + Keepalived)
* 본 가이드는 별도의 LBNode를 갖는 K8S 다중화 클러스터 구축을 위해 작성되었음.
* 구축하려는 LBNode에 해당 파일들이 같은 디렉터리 내에 존재해야 함.
## 구성 요소 및 버전
* Keepalived	v1.3.5	# LBNode에 설치
* HA-Proxy	v1.5.18	# LBNode에 설치
## Install Steps
0. 변수 설정
1. HAProxy + Keepalived 설치
2. 설치한 패키지 재시작
3. K8S 클러스터 구축

## Step 0. 변수 설정
* 목적 : `LB Node 구축을 위한 변수 설정`
* 순서 : 
	* Keepalived 와 HAProxy를 설치 및 동작시키기 위한 변수를 설정한다.
	* 클러스터 구성에 사용할 각 Master Node의 IP, VIP, LBNode에 대한 정보를 입력한다.
		```bash
		export MASTER1NAME=test		# 클러스터로 구성할 Master Node의 host명을 각각 입력.
		export MASTER2NAME=worker
		export MASTER3NAME=worker2
		
		export MASTER1IP=192.168.56.222 # Master Node의 IP를 각각 입력.
		export MASTER2IP=192.168.56.223
		export MASTER3IP=192.168.56.224
		
		export LB1=192.168.56.250	# 현재 LB Node의 IP를 입력.
		export LB2=192.168.56.249	# 다른 LB Node의 IP를 입력.
		
		export VIP=192.168.56.240	# VIP로 사용할 IP를 입력.
		```


## Step.1 HAProxy + Keepalived 설치
* 목적 : `설치 스크립트를 실행하여 HAProxy와 Keepalived를 LBNode에 설치`
* 순서 : 
	* 설치 스크립트에 실행 권한을 주고, 실행한다.
	```bash
	chmod +x lb_set_script.sh
	./lb_set_script.sh
	```


## Step.2 설치한 패키지 재시작
* 목적 : `HAProxy와 Keepalived 재시작`
* 순서 :
        * 각 패키지의 설정파일에 Step0 에서 입력한 값들이 올바르게 설정되었는지 확인한다.
	```bash
	vi /etc/keepalived/keepalived.conf
	vi /etc/haproxy/haproxy.cfg
	```

	* 각 패키지를 활성화시켜주며 재시작하고, 동작을 확인한다.
	```bash
	systemctl enable haproxy
	systemctl enable keepalived

	systemctl daemon-reload

	systemctl restart haproxy
	systemctl restart keepalived

	systemctl status haproxy
	systemctl status keepalived
	```


## Step.3 K8S 클러스터 구축
* 목적 : `LB Node 설정을 완료한 이후, K8S 클러스터 구축을 계속한다`
* 순서 :
	* 아래의 GUIDE에서, 3번, 3-1번을 제외하고 클러스터 구축을 수행한다.
	* [K8S MASTER INSTALL GUIDE](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/K8S_Master/README.md#k8s-master-%EC%84%A4%EC%B9%98-%EA%B0%80%EC%9D%B4%EB%93%9C)
