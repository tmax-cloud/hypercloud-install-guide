#!/bin/bash

install_dir=$(dirname "$0")
. ${install_dir}/k8s.config

yaml_dir="${install_dir}/yaml"

os_check=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

function set_env() {

  echo "========================================================================="
  echo "======================== set env for kubernetes  ========================"
  echo "========================================================================="
  
  # centos
  if [[ ${os_check} == "\"CentOS Linux\"" ]]; then

        # disable firewall
        sudo systemctl disable firewalld
        sudo systemctl stop firewalld

        #swapoff
        sudo swapoff -a
        sudo sed s/\\/dev\\/mapper\\/centos-swap/#\ \\/dev\\/mapper\\/centos-swap/g -i /etc/fstab

        #selinux mode
        sudo setenforce 0
        sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

  	#crio-kube set
  	sudo modprobe overlay
        sudo modprobe br_netfilter

	sudo cat << "EOF" | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf
	net.bridge.bridge-nf-call-iptables  = 1
	net.ipv4.ip_forward                 = 1
	net.bridge.bridge-nf-call-ip6tables = 1
EOF
	sudo sysctl --system

  # ubuntu
  elif [[ ${os_check} = "\"Ubuntu\"" ]]; then

	#swapoff
	sudo swapoff -a
	sudo sed s/\\/swap.img/#\ \\/swap.img/g -i /etc/fstab	

  # others 
  else
 	sudo echo "This OS is not supported."
	sudo exit 100
  fi

}

function install_crio() {

  echo  "========================================================================="
  echo  "==========================  start install crio =========================="
  echo  "========================================================================="

  #centos
  if [[ ${os_check} == "\"CentOS Linux\"" ]]; then

        # install crio
        sudo yum install -y cri-o
        sudo systemctl enable crio
        sudo systemctl start crio

        # check crio
        sudo systemctl status crio
        rpm -qi cri-o

        # remove cni0
        sudo rm -rf  /etc/cni/net.d/100-crio-bridge.conf
        sudo rm -rf  /etc/cni/net.d/200-loopback.conf

        # edit crio config
        sudo sed -i 's/\"\/usr\/libexec\/cni\"/\"\/usr\/libexec\/cni\"\,\"\/opt\/cni\/bin\"/g' /etc/crio/crio.conf
	sudo sed -i 's/\#insecure\_registries = \"\[\]\"/\insecure\_registries = \[\"{imageRegistry}\"\]/g' /etc/crio/crio.conf
	sudo sed -i 's/\#registries = \[/registries = \[\"{imageRegistry}\"\]/g' /etc/crio/crio.conf
        sed -i 's/k8s.gcr.io/{imageRegistry}\/k8s.gcr.io/g' /etc/crio/crio.conf
	sed -i 's/registry.fedoraproject.org/{imageRegistry}/g' /etc/containers/registries.conf 
	sudo sed -i "s|{imageRegistry}|${imageRegistry}|g" /etc/crio/crio.conf
        sudo sed -i "s|{imageRegistry}|${imageRegistry}|g" /etc/containers/registries.conf
	
	sudo systemctl restart crio
	
  else
        sudo systemctl restart crio  
  fi


}

function install_kube() {

  echo  "=========================================================================" 
  echo  "=======================  start install kubernetes  ======================"
  echo  "========================================================================="

  #install kubernetes
  if [[ -z ${k8sVersion} ]]; then
	k8sVersion=1.17.6
  else
	k8sVersion=${k8sVersion} 
  fi

  if [[ -z ${apiServer} ]]; then
	apiServer=127.0.0.1
  else
    	apiServer=${apiServer} 
  fi

  if [[ -z ${podSubnet} ]]; then
    	podSubnet=10.244.0.0/16
  else
   	podSubnet=${podSubnet} 
  fi

  # centos
  if [[ ${os_check} == "\"CentOS Linux\"" ]]; then

	#install kubernetes components
	sudo yum install -y kubeadm-${k8sVersion}-0 kubelet-${k8sVersion}-0 kubectl-${k8sVersion}-0
	sudo systemctl enable --now kubelet
  # ubuntu
  elif [[ ${os_check} = "\"Ubuntu\"" ]]; then

	#install kubernetes components
	sudo apt-get install -y kubeadm-${k8sVersion}-0 kubelet-${k8sVersion}-0 kubectl-${k8sVersion}-0
	sudo systemctl enable kubelet
  # others
  else
        echo "This OS is not supported."
        exit 100
  fi

  	sudo echo '1' > /proc/sys/net/ipv4/ip_forward
  	sudo echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

  	#change kubeadm yaml
  	sudo sed -i "s|{k8sVersion}|v${k8sVersion}|g" ${yaml_dir}/kubeadm-config.yaml
  	sudo sed -i "s|{apiServer}|${apiServer}|g" ${yaml_dir}/kubeadm-config.yaml
  	sudo sed -i "s|{podSubnet}|\"${podSubnet}\"|g" ${yaml_dir}/kubeadm-config.yaml
	sudo sed -i "s|{imageRegistry}|${imageRegistry}|g" ${yaml_dir}/kubeadm-config.yaml

  	# kube init
  	sudo kubeadm init --config=${yaml_dir}/kubeadm-config.yaml --upload-certs

  	mkdir -p $HOME/.kube
  	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  	sudo chown $(id -u):$(id -g) $HOME/.kube/config

  	echo  "========================================================================="
  	echo  "======================  complete install kubernetes  ===================="
  	echo  "========================================================================="

}

function uninstall() {

  kubeadm reset -f

  sudo sed -i "s|v${k8sVersion}|{k8sVersion}|g" ${yaml_dir}/kubeadm-config.yaml
  sudo sed -i "s|${apiServer}|{apiServer}|g" ${yaml_dir}/kubeadm-config.yaml
  sudo sed -i "s|\"${podSubnet}\"|{podSubnet}|g" ${yaml_dir}/kubeadm-config.yaml
  sudo sed -i "s|${imageRegistry}|{imageRegistry}|g" ${yaml_dir}/kubeadm-config.yaml
  
  sudo rm -rf $HOME/.kube

}

function install_calico() {

  #install calico
  if [[ -z ${calicoVersion} ]]; then
  	calicoVersion=3.13
  	kubectl apply -f ${yaml_dir}/calico.yaml
  else
  	kubectl apply -f calico.yaml
  fi


}

function main(){
  
  case "${1:-}" in
  up)
    set_env
    install_crio
    install_kube
    #install_calico
    ;;
  delete)
    uninstall
    ;;
  *)
    set +x
    echo " service list:" >&2
    echo "  $0 up" >&2
    echo "  $0 delete" >&2
    ;;
  esac
}
main $1

