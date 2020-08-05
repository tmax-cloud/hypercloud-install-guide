# kubeadm 클러스터 업그레이드 가이드

## 구성 요소 및 버전
* kubeadm, kubelet, kubectl

## Prerequisites
* upgrade 할 kubeadm version 선택
	```bash
	yum list --showduplicates kubeadm --disableexcludes=kubernetes
	```
* 하나의 MINOR 버전에서 다음 MINOR 버전으로, 또는 동일한 MINOR의 PATCH 버전 사이에서만 업그레이드할 수 있다. 
* 즉, 업그레이드할 때 MINOR 버전을 건너 뛸 수 없다. 예를 들어, 1.y에서 1.y+1로 업그레이드할 수 있지만, 1.y에서 1.y+2로 업그레이드할 수는 없다.
* ex) 1.15 버전에서 1.17 버전으로 한번에 업그레이드는 불가능 하다. 1.15 -> 1.16 -> 1.17 스텝을 진행 해야 한다.

## Steps
0. [master upgrade](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/K8S_Worker#step0-%ED%99%98%EA%B2%BD-%EC%84%A4%EC%A0%95)
1. [node upgrade](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/K8S_Worker#step-1-cri-o-%EC%84%A4%EC%B9%98)
2. [kubeadm, kubelet, kubectl 설치](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/K8S_Worker#step-2-kubeadm-kubelet-kubectl-%EC%84%A4%EC%B9%98)


## Step0. kubernetes master upgrade
* master에서 kubeadm을 upgrade 한다.


## Step1. kubernetes node upgrade
