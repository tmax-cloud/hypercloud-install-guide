#!/bin/bash

pkg_check=`which rpm >& /dev/null; echo $?`

rpm_pkg_list=("keepalived" "haproxy")
#rpm_need_install="yum install -y"
#dpkg_need_install=`apt-get install`

for pkgname in ${rpm_pkg_list[@]};
do
	pkg_check_cmd=`rpm -qa | grep "${list_num}" >& /dev/null; echo $?`
	if [ ${pkg_check_cmd} -eq 1 ];
	then
		rpm_need_install="yum install -y ${pkgname}"
		${rpm_need_install} 2>&1 > /dev/null
	else
		echo "${pkgname} is already installed!!"
	fi
done
