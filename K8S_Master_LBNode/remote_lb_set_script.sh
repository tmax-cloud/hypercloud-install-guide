#!/bin/sh

exp=$HOME/archive/keepalived_script/ssh_login.exp
expcopy=$HOME/archive/keepalived_script/scp_copy.exp
exprestart=$HOME/archive/keepalived_script/restart_pkg.exp
account=root #${1}
password=1234 #${2}
ipaddr="192.168.56.250 192.168.56.130" #${3}

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
