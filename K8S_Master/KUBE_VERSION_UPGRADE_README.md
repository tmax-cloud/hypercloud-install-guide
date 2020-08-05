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

## Step0. kubernetes master upgrade
* master에서 kubeadm을 upgrade 한다.
	```bash
	yum install -y kubeadm-설치버전 --disableexcludes=kubernetes
	ex) yum install -y kubeadm-1.17.6-0 --disableexcludes=kubernetes
	```
* 버전 확인
	```bash
	kubeadm version
	```
* 업그레이드 plan 변경
	```bash
	sudo kubeadm upgrade plan 
	```
   * 업그레이드 시 kubeadm config 변경이 필요할 경우
	```bash
	sudo kubeadm upgrade plan --config=kubeadm_config.yaml
	```
	```bash
	[upgrade/config] Making sure the configuration is correct:
	[upgrade/config] Reading configuration from the cluster...
	[upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
	[preflight] Running pre-flight checks.
	[upgrade] Running cluster health checks
	[upgrade] Fetching available versions to upgrade to
	[upgrade/versions] Cluster version: v1.17.3
	[upgrade/versions] kubeadm version: v1.18.0
	[upgrade/versions] Latest stable version: v1.18.0
	[upgrade/versions] Latest version in the v1.17 series: v1.18.0

	Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
	COMPONENT   CURRENT             AVAILABLE
	Kubelet     1 x v1.17.3   v1.18.0

	Upgrade to the latest version in the v1.17 series:

	COMPONENT            CURRENT   AVAILABLE
	API Server           v1.17.3   v1.18.0
	Controller Manager   v1.17.3   v1.18.0
	Scheduler            v1.17.3   v1.18.0
	Kube Proxy           v1.17.3   v1.18.0
	CoreDNS              1.6.5     1.6.7
	Etcd                 3.4.3     3.4.3-0

	You can now apply the upgrade by executing the following command:

    	kubeadm upgrade apply v1.18.0

	_____________________________________________________________________
	```	
## Step1. kubernetes node upgrade
