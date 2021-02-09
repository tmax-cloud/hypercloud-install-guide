#!/bin/bash

rpm_pkg_list=("keepalived" "haproxy")

for pkgname in ${rpm_pkg_list[@]};
do
	echo " "
	echo "*** ${pkgname} install... ***"
	echo " "
	rpm_need_install="sudo yum install -y ${pkgname}"
	${rpm_need_install}
done

echo " "
echo "*** Finish pkg installation ***"
echo " "
echo "*** File copying and modifying started ***"
echo " "

SCRIPTPATH=$(dirname `which $0`)

THISPATH=`echo $SCRIPTPATH`

sudo cp ${THISPATH}/notify_action.sh /etc/keepalived/notify_action.sh
sudo chmod +x /etc/keepalived/notify_action.sh

sudo mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf_back
sudo cp -f ${THISPATH}/keepalived_nolb.conf /etc/keepalived/keepalived.conf

sudo sed -i 's/MASTER1IP/'"$MASTER1IP"'/' /etc/keepalived/keepalived.conf
sudo sed -i 's/MASTER2IP/'"$MASTER2IP"'/' /etc/keepalived/keepalived.conf
sudo sed -i 's/MASTER3IP/'"$MASTER3IP"'/' /etc/keepalived/keepalived.conf

sudo sed -i 's/VIP/'"$VIP"'/' /etc/keepalived/keepalived.conf

sudo mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg_back
sudo cp -f ${THISPATH}/haproxy_nolb.cfg /etc/haproxy/haproxy.cfg

sudo sed -i 's/MASTER1NAME/'"$MASTER1NAME"'/' /etc/haproxy/haproxy.cfg
sudo sed -i 's/MASTER2NAME/'"$MASTER2NAME"'/' /etc/haproxy/haproxy.cfg
sudo sed -i 's/MASTER3NAME/'"$MASTER3NAME"'/' /etc/haproxy/haproxy.cfg

sudo sed -i 's/MASTER1IP/'"$MASTER1IP"'/' /etc/haproxy/haproxy.cfg
sudo sed -i 's/MASTER2IP/'"$MASTER2IP"'/' /etc/haproxy/haproxy.cfg
sudo sed -i 's/MASTER3IP/'"$MASTER3IP"'/' /etc/haproxy/haproxy.cfg

sudo sed -i 's/MASTERPORT/'"$MASTERPORT"'/' /etc/haproxy/haproxy.cfg
sudo sed -i 's/HAPROXYLBPORT/'"$HAPROXYLBPORT"'/' /etc/haproxy/haproxy.cfg

echo " "
echo "*** Finish file copying and modifying ***"
echo " "
echo "*** Finish all task in this script ***"
echo " "
