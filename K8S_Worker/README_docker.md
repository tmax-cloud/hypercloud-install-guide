
# k8s-node 설치 가이드

## 구성 요소 및 버전
* cri-o (v1.17.4)
* kubeadm, kubelet, kubectl (v1.17.6)

## Prerequisites

## Install Steps
0. [환경 설정](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/K8S_Worker#step0-%ED%99%98%EA%B2%BD-%EC%84%A4%EC%A0%95)
1. [cri-o 설치](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/K8S_Worker#step-1-cri-o-%EC%84%A4%EC%B9%98)
2. [kubeadm, kubelet, kubectl 설치](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/K8S_Worker#step-2-kubeadm-kubelet-kubectl-%EC%84%A4%EC%B9%98)
3. [kubernetes cluster join](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/K8S_Worker#step-2-kubeadm-kubelet-kubectl-%EC%84%A4%EC%B9%98)

## Step0. 환경 설정
* 목적 : `k8s 설치 진행을 위한 os 환경 설정`
* 순서 : 
    * os hostname을 설정한다.
	```bash
	sudo hostnamectl set-hostname k8s-master
	```
    * hostname과 ip를 등록한다.
      * sudo vi /etc/hosts
	```bash
	127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
	::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

	172.22.5.2 k8s-master
	```
    * 방화벽(firewall)을 해제한다. 
	```bash
	sudo systemctl stop firewalld
	sudo systemctl disable firewalld
	```	
    * 스왑 메모리를 비활성화 한다. 
	```bash
	sudo swapoff -a
	```
    * 스왑 메모리 비활성화 영구설정
      * sudo vi /etc/fstab 
	```bash
	swap 관련 부분 주석처리
	# /dev/mapper/centos-swap swap                    swap    defaults        0
	```
    ![image](figure/fstab.PNG)
    * SELinux 설정을 해제한다. 
	```bash
	sudo setenforce 0
	sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
	```
    *  설정
	```bash
	sudo cat << "EOF" | sudo tee -a /etc/sysctl.d/k8s.conf
	net.bridge.bridge-nf-call-iptables  = 1
	net.ipv4.ip_forward                 = 1
	net.bridge.bridge-nf-call-ip6tables = 1
	EOF
	
	sudo sysctl --system
	```
  
## Step 1. docker 설치 및 설정
* 목적 : `k8s container runtime 설치`
* 생성 순서 : 
    * docker-ce를 설치한다. image registry 구축 시에 docker를 이미 설치하였고 daemon.json 내용이 같다면 step2를 진행한다.
    ```bash
    $ sudo yum install -y docker-ce
    $ sudo systemctl start docker
    $ sudo systemctl enable docker
    ```
    * 폐쇄망 환경에서 private registry 접근 및 cgroup 설정을 위해 daemon.json 내용을 수정한다.
      * sudo vi /etc/docker/daemon.json
    ```bash
    {
        "exec-opts": ["native.cgroupdriver=systemd"],
        "insecure-registries": ["{IP}:5000"]
    }
    ```
    * docker를 재실행하고 status를 확인한다.
    ```bash
    $  sudo systemctl restart docker
    $  sudo systemctl status docker
    ```  
* 비고 : 
    * registries.conf 내용을 수정한다.
      * sudo vi /etc/containers/registries.conf
	```bash
	unqualified-search-registries = ['registry.fedoraproject.org', 'registry.access.redhat.com', 'registry.centos.org', 'docker.io', '{registry}:{port}']
	ex) unqualified-search-registries = ['registry.fedoraproject.org', 'registry.access.redhat.com', 'registry.centos.org', 'docker.io', '172.22.5.2:5000']
	``` 	      
    * docker를 재시작 한다.
	```bash
	sudo systemctl restart docker
	```
## Step 2. kubeadm, kubelet, kubectl 설치
* 목적 : `Kubernetes 구성을 위한 kubeadm, kubelet, kubectl 설치한다.`
* 순서:
    * (폐쇄망) kubeadm, kubectl, kubelet 설치 (v1.17.6)
	```bash
	sudo yum install -y kubeadm-1.17.6-0 kubelet-1.17.6-0 kubectl-1.17.6-0
	
	sudo systemctl enable kubelet
	```  	
    * (외부망) 레포 등록 후 kubeadm, kubectl, kubelet 설치 (v1.17.6)
	```bash
	sudo cat << "EOF" | sudo tee -a /etc/yum.repos.d/kubernetes.repo
	[kubernetes]
	name=Kubernetes
	baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
	enabled=1
	gpgcheck=1
	repo_gpgcheck=1
	gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
	EOF

	sudo yum install -y kubeadm-1.17.6-0 kubelet-1.17.6-0 kubectl-1.17.6-0
	
	sudo systemctl enable kubelet
	```  
  
## Step 3. kubernetes cluster join
* 목적 : `kubernetes cluster에 join한다.`
* 순서 :
    * kubernetes master 구축시 생성된 join token을 worker node에서 실행한다.
    * kubeadm join
	```bash
	kubeadm join 172.22.5.2:6443 --token r5ks9p.q0ifuz5pcphqvc14 \ --discovery-token-ca-cert-hash sha256:90751da5966ad69a49f2454c20a7b97cdca7f125b8980cf25250a6ee6c804d88
	```
    ![image](figure/noding.PNG)
* 비고 : 
    * kubeadm join command를 저장해놓지 못한 경우, master node에서 아래 명령어를 통해 token 재생성이 가능하다.
	```bash
	kubeadm token create --print-join-command
	```	
