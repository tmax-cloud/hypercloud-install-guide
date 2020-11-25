# K8S Master 클러스터의 LBNode 설치 가이드(HAProxy + Keepalived)
* 본 가이드는 별도의 LBNode를 갖는 K8S 다중화 클러스터 구축을 위해 작성되었음.
* 원격으로 LBNode에 pkg를 설치할 수 있도록 하였으므로, 구축하려는 LBNode에 ssh 연결이 가능해야 함.
## 구성 요소 및 버전
* Keepalived	v1.3.5	# LBNode에 설치
* HA-Proxy	v1.5.18	# LBNode에 설치
* expect	v5.45	# 작업을 ssh로 수행할 경우, 직접 ssh 연결이 가능한 node에 설치
## Install Steps
0. 설정파일 수정
1. Expect 설치
2. HAProxy + Keepalived 설치

## Step 0. 설정파일 수정
* 목적 : `LB Node 구축을 위한 설정파일 수정`
* 순서 : 
	* keepalived 설정파일인 keepalived.conf 파일을 수정한다.
	* 클러스터 구성에 사용할 VIP와LBNode에 대한 정보를 입력한다.
		```bash
		global_defs {
		    script_user root root
		    enable_script_security off
		}
		
		vrrp_script chk_haproxy { # haproxy 상태 모니터링을 위한 스크립트
		    script "/usr/sbin/pidof haproxy"
		    interval 2
		    weight 2
		}
		
		vrrp_instance VI_1 {
		    state MASTER # MASTER는 메인 LB, 백업 LB는  BACKUP 으로 설정
		    interface enp0s8 # VIP 사용할 interface
		    virtual_router_id 51
		    priority 100 # MASTER는 우선순위를 높게, BACKUP은 MASTER보다 1 낮게 설정.
		    advert_int 1
		    nopreempt
		    authentication { # auth를 위한 password 설정
		        auth_type PASS
		        auth_pass 1111
		    }
		
		    unicast_src_ip 192.168.56.120 # LB 서버 local ip
		
		    unicast_peer {
		        192.168.56.121 # 다른 LB 서버 local ip
		    }
		
		    virtual_ipaddress {
		        192.168.56.200 # VIP로사용할 IP설정. 기존 VIP로 구성된 클러스터가 있다면 VIP를 같게 설정.
		    }
		
		    notify_master "/bin/sh /etc/keepalived/notify_action.sh MASTER"
		    notify_backup "/bin/sh /etc/keepalived/notify_action.sh BACKUP"
		    notify_fault "/bin/sh /etc/keepalived/notify_action.sh FAULT"
		    notify_stop "/bin/sh /etc/keepalived/notify_action.sh STOP"
		
		    track_script {
		        chk_haproxy
		    }
		
		    track_interface { # VIP로 사용하는 대역을 갖는 interface
		        enp0s8
		    }
		}
		```
	
	* HAProxy 설정파일인 haproxy.cfg 파일을 수정한다.
		```bash
		global
		  log 127.0.0.1 local2
		  maxconn 2000
		  uid 0
		  gid 0
		  daemon # background process
		
		defaults
		  log global # global 설정 사용
		  mode tcp # SSL 통신을 위해서는 TCP모드로 (http모드는 SSL 안됨)
		  option tcplog
		  option dontlognull # 데이터가 전송되지 않은 연결 로깅 제외
		  retries 3 # 연결요청 재시도 횟수
		  maxconn 2000 #option redispatch
		  timeout connect 10s
		  timeout client 1m
		  timeout server 1m
		
		frontend k8s-api
		  bind 0.0.0.0:6443
		  default_backend k8s-api
		
		backend k8s-api
		  option tcp-check
		  balance roundrobin
		  server master1 192.168.56.104:6443 check # 클러스터를 구성하는 Master 서버들 정보를 입력.
		  server master2 192.168.56.103:6443 check # 각 노드의 Hostname과 IP주소로 수정.
		  server master3 192.168.56.105:6443 check
		```

## Step.1 Expect 설치
* 본 Step.1 은 LBNode에 원격으로 접근이 가능한 서버에서 필요합니다.
* 본 Step.1 은 HAProxy와 Keepalived를 LBNode에 직접 설치하는 경우에는 Skip합니다.
* HAProxy와 Keepalived를 LBNode에 직접 설치하는 경우에는 Step.2-A를 수행합니다.
* 목적 : `설치 스크립트를 수행하기 위해 LBNode에 접근할 수 있는 서버에 설치`
* 순서 : 
	* Expect pkg를 설치한다.
	```bash
	yum install -y expect
	```
	
	* Expect pkg를 설치한 경우, 다음으로 Step.2-B를 수행한다.


## Step.2-A HAProxy + Keepalived 설치
* 목적 : `LBNode 구축을 위한 HAProxy와 Keepalived 설치`
* 순서 :
        * lb_set_script.sh 파일을 실행한다.
	```bash
	sh lb_set_script.sh
	```


## Step.2-B HAProxy + Keepalived 설치
* 목적 : `LBNode 구축을 위한 HAProxy와 Keepalived 설치`
* 순서 :
	* remote_lb_set_script.sh 파일을 수정한다.
	```bash
	#!/bin/sh
	
	exp=$HOME/archive/keepalived_script/ssh_login.exp		# ssh_login.exp 파일 경로 수정
	expcopy=$HOME/archive/keepalived_script/scp_copy.exp		# scp_copy.exp 파일 경로 수정
	exprestart=$HOME/archive/keepalived_script/restart_pkg.exp	# restart_pkg.exp 파일 경로 수정
	account=root # ssh로 접근가능한 LBNode의 계정
	password=1234 # ssh로 접근가능한 LBNode의 password
	ipaddr="192.168.56.250 192.168.56.130" # ssh로 접근하려는 LBNode의 IP주소를 공백으로 구분하여 입력.

	pkglist=("keepalived" "haproxy")

	for svr in $ipaddr
	do
        	case "${svr}" in
	        *)
        	        for pkgname in ${pkglist[@]};
                	do
                        	$exp $account $password ${svr} ${pkgname};
			
	                        if [ "${pkgname}" == "keepalived" ]; then
                        	      $expcopy $account $password ${svr} ${pkgname} ${pkgname}.conf
	                        elif [ "${pkgname}" == "haproxy" ]; then
        	                      $expcopy $account $password ${svr} ${pkgname} ${pkgname}.cfg
                	        fi

				$exprestart $account $password ${svr} ${pkgname};
	                done
        	        ;;
	        esac
        	sleep 0.5
	done

	```

	* remote_lb_set_script.sh 파일을 실행한다.
	```bash
	sh remote_lb_set_script.sh
	```
