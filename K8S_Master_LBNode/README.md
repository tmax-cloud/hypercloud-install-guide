# K8S Master 클러스터의 LBNode 설치 가이드(HAProxy + Keepalived)
* 본 가이드는 A, B로 구성.
* [A는 별도의 LBNode를 갖는 K8S 다중화 클러스터 구축을 위해 작성](#a-%EB%B3%84%EB%8F%84%EC%9D%98-lbnode%EB%A5%BC-%EA%B0%96%EB%8A%94-%EA%B2%BD%EC%9A%B0)되었음.
	* 구축하려는 LBNode에 해당 파일들이 같은 디렉터리 내에 존재해야 함.
	* LBNode 각각에서 아래의 작업들을 동일하게 수행해야 함.
* [B는 별도의 LBNode 없이, K8S 다중화 클러스터 내에서 HAProxy가 동작하도록 작성](#b-%EB%B3%84%EB%8F%84%EC%9D%98-lbnode%EB%A5%BC-%EA%B0%96%EC%A7%80-%EC%95%8A%EA%B3%A0-%ED%81%B4%EB%9F%AC%EC%8A%A4%ED%84%B0-%EB%82%B4%EC%97%90%EC%84%9C-haproxy%EB%A5%BC-%EB%8F%99%EC%9E%91%EC%8B%9C%ED%82%AC-%EA%B2%BD%EC%9A%B0)되었음.
	* 구축하려는 MasterNode에 해당 파일들이 같은 디렉터리 내에 존재해야 함.
	* MasterNode 각각에서 아래의 작업들을 동일하게 수행해야 함.
# A. 별도의 LBNode를 갖는 경우
## 구성 요소 및 버전
* Keepalived	v1.3.5	# LBNode에 설치
* HA-Proxy	v1.5.18	# LBNode에 설치
## Install Steps
0. 변수 설정 및 준비
1. HAProxy + Keepalived 설치
2. 설치한 서비스 기동
3. K8S 클러스터 구축

## Step 0. 변수 설정 및 준비
* 목적 : `LB Node 구축을 위한 변수 설정 및 준비과정`
* 순서 : 
	* Keepalived 와 HAProxy를 설치 및 동작시키기 위한 변수를 설정한다.
	* 클러스터 구성에 사용할 각 Master Node의 IP, VIP, LBNode에 대한 정보를 입력한다.
		```bash
		export MASTER1NAME=master1hostname		# 클러스터로 구성할 Master Node의 host명을 각각 입력.
		export MASTER2NAME=master2hostname
		export MASTER3NAME=master3hostname
		
		export MASTER1IP=192.168.56.222 # Master Node의 IP를 각각 입력.
		export MASTER2IP=192.168.56.223
		export MASTER3IP=192.168.56.224
		
		export MASTERPORT=6443		# 기본적으로 Master Port는 6443을 사용.
		export HAPROXYLBPORT=16443	# Master 와 동일한 Node에 설치시 반드시 MASTERPORT와 다른 Port를 사용해야 하며, 이경우 Master Join시에 이 변수로 설정한 Port를 사용해야 함.
		
		export LB1=192.168.56.250	# 현재 LB Node의 IP를 입력.
		export LB2=192.168.56.249	# 다른 LB Node의 IP를 입력.
		
		export VIP=192.168.56.240	# K8S Master Join시VIP로 사용할 IP를 입력.
		```
	
	* LB Node 구축을 위해 필요한 파일들을 동일한 위치에 다운로드 받는다.
		```bash
		wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/master/K8S_Master_LBNode/haproxy.cfg
		wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/master/K8S_Master_LBNode/keepalived.conf
		wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/master/K8S_Master_LBNode/lb_set_script.sh
		wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/master/K8S_Master_LBNode/notify_action.sh
		```

	* SELinux 관련 플래그를 설정한다.
		```bash
		sudo setsebool -P haproxy_connect_any=1
		```
	
	* LBNode에서 동작 중인 firewalld를 중지 및 비활성화 한다.
		```bash
		sudo systemctl stop firewalld && sudo systemctl disable firewalld
		```


## Step.1 HAProxy + Keepalived 설치
* 목적 : `설치 스크립트를 실행하여 HAProxy와 Keepalived를 LBNode에 설치`
* 순서 : 
	* 설치 스크립트에 실행 권한을 주고, 실행한다.
	```bash
	sudo chmod +x lb_set_script.sh
	sudo ./lb_set_script.sh
	```


## Step.2 설치한 서비스 기동
* 목적 : `HAProxy와 Keepalived 기동`
* 순서 :
	* 각 서비스의 설정파일에 Step0 에서 입력한 값들이 올바르게 설정되었는지 확인한다.
	```bash
	sudo vi /etc/keepalived/keepalived.conf
	sudo vi /etc/haproxy/haproxy.cfg
	```

	* Keepalived 설정파일의 세부내용을 확인/수정한다.
	* state 필드는 MASTER or BACKUP을 반드시 수정하며, priority 또한 수정한다.
	* interface도 수정해줘야한다.
	* unicast_src_ip 는 현재 설치 진행 중인 LB 서버(앞서 설정한 LB1 변수)이다.
	* unicast_peer 는 다른 LB 서버(앞서 설정한 LB2 변수)이다.
	```bash
	global_defs {
	    script_user root root
	    enable_script_security off
	}
	
	vrrp_script chk_haproxy {
	    script "/usr/sbin/pidof haproxy"
	    interval 2
	    weight 2
	}
	
	vrrp_instance VI_1 {
	    state MASTER        # MASTER는 메인 LB, 백업 LB는  BACKUP 으로 설정
	    interface enp0s8    # 사용할 interface
	    virtual_router_id 51
	    priority 100        # MASTER의 우선순위를 가장 높게(ex. 100), BACKUP의 경우 그보다 낮게(ex. 99, 98) 설정.
	    advert_int 1
	    authentication {    # 인증에 사용될 password(동일하게 맞춰주기만 하면 됨)
	        auth_type PASS
	        auth_pass 1111
	    }
	
	    unicast_src_ip LB1  # LB 서버 local ip
	
	    unicast_peer {
	        LB2             # 다른 LB 서버 local ip
	    }
	
	    virtual_ipaddress {
	        VIP             # 클러스터 구성에 사용될 VIP!
	    }
	
	    notify_master "/bin/sh /etc/keepalived/notify_action.sh MASTER"
	    notify_backup "/bin/sh /etc/keepalived/notify_action.sh BACKUP"
	    notify_fault "/bin/sh /etc/keepalived/notify_action.sh FAULT"
	    notify_stop "/bin/sh /etc/keepalived/notify_action.sh STOP"
	
	    track_script {
	        chk_haproxy
	    }
	
	    track_interface {
	        enp0s8          # 사용할 interface
	    }
	}
	```

	* HA Proxy 설정파일의 세부내용을 확인/수정한다.
	```bash
	global
	  log 127.0.0.1 local2
	  maxconn 2000
	  uid 0
	  gid 0
	  daemon                # background process
	
	defaults
	  log global            # global 설정 사용
	  mode tcp              # SSL 통신을 위해서는 TCP모드로 (http모드는 SSL 안됨)
	  option tcplog
	  option dontlognull    # 데이터가 전송되지 않은 연결 로깅 제외
	  retries 3             # 연결요청 재시도 횟수
	  maxconn 2000          #option redispatch
	  timeout connect 10s
	  timeout client 1m
	  timeout server 1m
	
	frontend k8s-api
	  bind 0.0.0.0:HAPROXYLBPORT	# Master Node와 동일 Node에 설치시, Master Join을 해당 port로 해야함.
	  default_backend k8s-api
	
	backend k8s-api
	  option tcp-check
	  balance roundrobin
	  server MASTER1NAME MASTER1IP:MASTERPORT check # Master 다중화 서버들 정보 기재
	  server MASTER2NAME MASTER2IP:MASTERPORT check
	  server MASTER3NAME MASTER3IP:MASTERPORT check
	```

	* 각 서비스를 활성화시켜주며 기동하고, 동작을 확인한다.
	```bash
	sudo systemctl enable keepalived
	sudo systemctl enable haproxy

	sudo systemctl daemon-reload

	sudo systemctl start keepalived
	sudo systemctl start haproxy

	sudo systemctl status keepalived
	sudo systemctl status haproxy
	```

## Step.3 K8S 클러스터 구축
* 목적 : `LB Node 설정을 완료한 이후, K8S 클러스터 구축을 계속한다`
* 순서 :
	* 아래의 GUIDE에서, 3-1번을 제외하고 클러스터 구축을 수행한다.
	* [K8S MASTER INSTALL GUIDE](https://github.com/tmax-cloud/hypercloud-install-guide/tree/4.1/K8S_Master#k8s-master-%EC%84%A4%EC%B9%98-%EA%B0%80%EC%9D%B4%EB%93%9C)


# B. 별도의 LBNode를 갖지 않고, 클러스터 내에서 HAProxy를 동작시킬 경우
## 구성 요소 및 버전
* Keepalived	v1.3.5	# MasterNode에 설치
* HA-Proxy	v1.5.18	# MasterNode에 설치
## Install Steps
0. 변수 설정 및 준비
1. HAProxy + Keepalived 설치
2. 설치한 서비스 기동
3. K8S 클러스터 구축

## Step 0. 변수 설정 및 준비
* 목적 : `HAProxy Node 구축을 위한 변수 설정 및 준비과정`
* 순서 :
	* Keepalived 와 HAProxy를 설치 및 동작시키기 위한 변수를 설정한다.
	* 클러스터 구성에 사용할 각 Master Node의 IP, VIP에 대한 정보를 입력한다.
		```bash
		export MASTER1NAME=master1hostname		# 클러스터로 구성할 Master Node의 host명을 각각 입력.
		export MASTER2NAME=master2hostname
		export MASTER3NAME=master3hostname

		export MASTER1IP=192.168.56.222	# 현재 Node의 IP를 입력.
		export MASTER2IP=192.168.56.223	# 다른 Node의 IP를 입력.
		export MASTER3IP=192.168.56.224	# 다른 Node의 IP를 입력.

		export MASTERPORT=6443		# 기본적으로 Master Port는 6443을 사용.
		export HAPROXYLBPORT=16443	# 반드시 MASTERPORT와 다른 Port를 사용해야 하며, 이경우 Master Join시에 이 변수로 설정한 Port를 사용해야 함.

		export VIP=192.168.56.240	# K8S Master Join시VIP로 사용할 IP를 입력.
		```

	* Node 구축을 위해 필요한 파일들을 동일한 위치에 다운로드 받는다.
		```bash
		wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/master/K8S_Master_LBNode/haproxy_nolb.cfg
		wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/master/K8S_Master_LBNode/keepalived_nolb.conf
		wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/master/K8S_Master_LBNode/lb_set_script_nolb.sh
		wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/master/K8S_Master_LBNode/notify_action.sh
		```

	* SELinux 관련 플래그를 설정한다.
		```bash
		sudo setsebool -P haproxy_connect_any=1
		```

	* Node에서 동작 중인 firewalld를 중지 및 비활성화 한다.
		```bash
		sudo systemctl stop firewalld && sudo systemctl disable firewalld
		```


## Step.1 HAProxy + Keepalived 설치
* 목적 : `설치 스크립트를 실행하여 HAProxy와 Keepalived를 MasterNode에 설치`
* 순서 :
	* 설치 스크립트에 실행 권한을 주고, 실행한다.
	```bash
	sudo chmod +x lb_set_script_nolb.sh
	sudo ./lb_set_script_nolb.sh
	```


## Step.2 설치한 서비스 기동
* 목적 : `HAProxy와 Keepalived 기동`
* 순서 :
	* 각 서비스의 설정파일에 Step0 에서 입력한 값들이 올바르게 설정되었는지 확인한다.
	```bash
	sudo vi /etc/keepalived/keepalived_nolb.conf
	sudo vi /etc/haproxy/haproxy_nolb.cfg
	```

	* Keepalived 설정파일의 세부내용을 확인/수정한다.
	* state 필드는 MASTER or BACKUP을 반드시 수정하며, priority 또한 수정한다.
	* interface도 수정해줘야한다.
	* unicast_src_ip 는 현재 설치 진행 중인 서버(앞서 설정한 MASTER1IP 변수)이다.
	* unicast_peer 는 다른 LB 서버(앞서 설정한 MASTER2IP, MASTER3IP 변수)이다.
	```bash
	global_defs {
	    script_user root root
	    enable_script_security off
	}

	vrrp_script chk_haproxy {
	    script "/usr/sbin/pidof haproxy"
	    interval 2
	    weight 2
	}

	vrrp_instance VI_1 {
	    state MASTER        # MASTER는 메인 Node, 백업 Node는  BACKUP 으로 설정
	    interface enp0s8    # 사용할 interface
	    virtual_router_id 51
	    priority 100        # MASTER의 우선순위를 가장 높게(ex. 100), BACKUP의 경우 그보다 낮게(ex. 99, 98) 설정.
	    advert_int 1
	    authentication {    # 인증에 사용될 password(동일하게 맞춰주기만 하면 됨)
	        auth_type PASS
	        auth_pass 1111
	    }

	    unicast_src_ip MASTER1IP  # 현재 설치 중인 Node의 local ip

	    unicast_peer {
	        MASTER2IP             # 다른 Node의 local ip
		MASTER3IP
	    }

	    virtual_ipaddress {
	        VIP             # 클러스터 구성에 사용될 VIP!
	    }

	    notify_master "/bin/sh /etc/keepalived/notify_action.sh MASTER"
	    notify_backup "/bin/sh /etc/keepalived/notify_action.sh BACKUP"
	    notify_fault "/bin/sh /etc/keepalived/notify_action.sh FAULT"
	    notify_stop "/bin/sh /etc/keepalived/notify_action.sh STOP"

	    track_script {
	        chk_haproxy
	    }

	    track_interface {
	        enp0s8          # 사용할 interface
	    }
	}
	```

	* HA Proxy 설정파일의 세부내용을 확인/수정한다.
	```bash
	global
	  log 127.0.0.1 local2
	  maxconn 2000
	  uid 0
	  gid 0
	  daemon                # background process

	defaults
	  log global            # global 설정 사용
	  mode tcp              # SSL 통신을 위해서는 TCP모드로 (http모드는 SSL 안됨)
	  option tcplog
	  option dontlognull    # 데이터가 전송되지 않은 연결 로깅 제외
	  retries 3             # 연결요청 재시도 횟수
	  maxconn 2000          #option redispatch
	  timeout connect 10s
	  timeout client 1m
	  timeout server 1m

	frontend k8s-api
	  bind 0.0.0.0:HAPROXYLBPORT	# Master Node와 동일 Node에 설치시, Master Join을 해당 port로 해야함.
	  default_backend k8s-api

	backend k8s-api
	  option tcp-check
	  balance roundrobin
	  server MASTER1NAME MASTER1IP:MASTERPORT check # Master 다중화 서버들 정보 기재
	  server MASTER2NAME MASTER2IP:MASTERPORT check
	  server MASTER3NAME MASTER3IP:MASTERPORT check
	```

	* 각 서비스를 활성화시켜주며 기동하고, 동작을 확인한다.
	```bash
	sudo systemctl enable keepalived
	sudo systemctl enable haproxy

	sudo systemctl daemon-reload

	sudo systemctl start keepalived
	sudo systemctl start haproxy

	sudo systemctl status keepalived
	sudo systemctl status haproxy
	```

## Step.3 K8S 클러스터 구축
* 목적 : `이후, K8S 클러스터 구축을 계속한다`
* 순서 :
	* 아래의 GUIDE에서, 3-1번을 제외하고 클러스터 구축을 수행한다.
	* [K8S MASTER INSTALL GUIDE](https://github.com/tmax-cloud/hypercloud-install-guide/tree/4.1/K8S_Master#k8s-master-%EC%84%A4%EC%B9%98-%EA%B0%80%EC%9D%B4%EB%93%9C)
