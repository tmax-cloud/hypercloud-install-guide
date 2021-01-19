#!/bin/bash

pkg_check=`which rpm >& /dev/null; echo $?`

rpm_pkg_list=("keepalived" "haproxy")
#rpm_need_install="yum install -y"
#dpkg_need_install=`apt-get install`

for pkgname in ${rpm_pkg_list[@]};
do
	#pkg_check_cmd=`rpm -qa | grep "${list_num}" >& /dev/null; echo $?`
	#if [ ${pkg_check_cmd} -eq 0 ];
	#then
		rpm_need_install="sudo yum install -y ${pkgname}"
		${rpm_need_install} 2>&1 > /dev/null
	#else
	#	echo "${pkgname} is already installed!!"
	#fi
done

SCRIPTPATH=$(dirname `which $0`)

THISPATH=`echo $SCRIPTPATH`

sudo cp ${THISPATH}/notify_action.sh /etc/keepalived/notify_action.sh
sudo chmod +x /etc/keepalived/notify_action.sh

sudo mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf_back
sudo cp -f ${THISPATH}/keepalived.conf /etc/keepalived/keepalived.conf

sudo sed -i 's/LB1/'"$LB1"'/' /etc/keepalived/keepalived.conf
sudo sed -i 's/LB2/'"$LB2"'/' /etc/keepalived/keepalived.conf

sudo sed -i 's/VIP/'"$VIP"'/' /etc/keepalived/keepalived.conf

sudo mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg_back
sudo cp -f ${THISPATH}/haproxy.cfg /etc/haproxy/haproxy.cfg

sudo sed -i 's/MASTER1NAME/'"$MASTER1NAME"'/' /etc/haproxy/haproxy.cfg
sudo sed -i 's/MASTER2NAME/'"$MASTER2NAME"'/' /etc/haproxy/haproxy.cfg
sudo sed -i 's/MASTER3NAME/'"$MASTER3NAME"'/' /etc/haproxy/haproxy.cfg

sudo sed -i 's/MASTER1IP/'"$MASTER1IP"'/' /etc/haproxy/haproxy.cfg
sudo sed -i 's/MASTER2IP/'"$MASTER2IP"'/' /etc/haproxy/haproxy.cfg
sudo sed -i 's/MASTER3IP/'"$MASTER3IP"'/' /etc/haproxy/haproxy.cfg

sudo sed -i 's/MASTERPORT/'"$MASTERPORT"'/' /etc/haproxy/haproxy.cfg
