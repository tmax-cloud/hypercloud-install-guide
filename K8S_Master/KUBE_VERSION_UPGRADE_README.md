# kubeadm 클러스터 업그레이드 가이드

## 구성 요소 및 버전
* kubeadm, kubelet, kubectl

## Prerequisites
* upgrade 할 kubeadm version 선택
	```bash
	yum list --showduplicates kubeadm --disableexcludes=kubernetes
	```

## Steps
0. [master upgrade](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/K8S_Worker#step0-%ED%99%98%EA%B2%BD-%EC%84%A4%EC%A0%95)
1. [node upgrade](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/K8S_Worker#step-1-cri-o-%EC%84%A4%EC%B9%98)
2. [kubeadm, kubelet, kubectl 설치](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/K8S_Worker#step-2-kubeadm-kubelet-kubectl-%EC%84%A4%EC%B9%98)


## Step0. kubernetes master upgrade
* master에서 kubeadm을 upgrade 한다.


## Step1. kubernetes node upgrade
