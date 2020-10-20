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
* runtime으로 crio 사용시, CRI-O 메이저와 마이너 버전은 쿠버네티스 메이저와 마이너 버전이 일치해야 한다. 따라서 업데이트한 쿠버네티스 버전에 따라 crio 버전도 함께 업데이트 한다.

## 폐쇄망 가이드 
1. **폐쇄망에서 설치하는 경우** 아래 가이드를 참고 하여 image registry를 먼저 구축한다.
    * https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Image_Registry   
2. 사용하는 image repository에 k8s 설치 시 필요한 이미지를 push한다. 
    * 작업 디렉토리 생성 및 환경 설정
    ```bash
    $ mkdir -p ~/k8s-install
    $ cd ~/k8s-install
    ```
    * 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받는다. (1.15.x -> 1.17.x으로 upgrade 하는 경우 두 버전의 image들이 모두 필요하다)
    * v1.16.15 images
     ```bash
    $ sudo docker pull k8s.gcr.io/kube-proxy:v1.16.15
    $ sudo docker pull k8s.gcr.io/kube-apiserver:v1.16.15
    $ sudo docker pull k8s.gcr.io/kube-controller-manager:v1.16.15
    $ sudo docker pull k8s.gcr.io/kube-scheduler:v1.16.15
    $ sudo docker pull k8s.gcr.io/etcd:3.3.15-0
    $ sudo docker pull k8s.gcr.io/coredns:1.6.2
    $ sudo docker pull k8s.gcr.io/pause:3.1    
    ```
    * v1.17.6 images
    ```bash
    $ sudo docker pull k8s.gcr.io/kube-proxy:v1.17.6
    $ sudo docker pull k8s.gcr.io/kube-apiserver:v1.17.6
    $ sudo docker pull k8s.gcr.io/kube-controller-manager:v1.17.6
    $ sudo docker pull k8s.gcr.io/kube-scheduler:v1.17.6
    $ sudo docker pull k8s.gcr.io/etcd:3.4.3-0
    $ sudo docker pull k8s.gcr.io/coredns:1.6.5
    $ sudo docker pull k8s.gcr.io/pause:3.1
    ```
    
    * docker image를 tar로 저장한다.
    * v1.16.15 images
    ```bash
    $ sudo docker save -o kube-proxy-1.16.tar k8s.gcr.io/kube-proxy:v1.16.15
    $ sudo docker save -o kube-controller-manager-1.16.tar k8s.gcr.io/kube-apiserver:v1.16.15
    $ sudo docker save -o etcd-1.16.tar k8s.gcr.io/etcd:3.3.15-0
    $ sudo docker save -o coredns-1.16.tar k8s.gcr.io/coredns:1.6.2
    $ sudo docker save -o kube-scheduler-1.16.tar k8s.gcr.io/kube-scheduler:v1.16.15
    $ sudo docker save -o kube-apiserver-1.16.tar k8s.gcr.io/kube-apiserver:v1.16.15
    $ sudo docker save -o pause-1.16.tar k8s.gcr.io/pause:3.1
    ```
    * v1.17.6 images
    ```bash
    $ sudo docker save -o kube-proxy-1.17.tar k8s.gcr.io/kube-proxy:v1.17.6
    $ sudo docker save -o kube-controller-manager-1.17.tar k8s.gcr.io/kube-controller-manager:v1.17.6
    $ sudo docker save -o etcd-1.17.tar k8s.gcr.io/etcd:3.4.3-0
    $ sudo docker save -o coredns-1.17.tar k8s.gcr.io/coredns:1.6.5
    $ sudo docker save -o kube-scheduler-1.17.tar k8s.gcr.io/kube-scheduler:v1.17.6
    $ sudo docker save -o kube-apiserver-1.17.tar k8s.gcr.io/kube-apiserver:v1.17.6
    $ sudo docker save -o pause-1.17.tar k8s.gcr.io/pause:3.1
    ```
3. 위의 과정에서 생성한 tar 파일들을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 이미지를 push한다.
    * v1.16.15 images
    ```bash
    $ sudo docker load -i kube-apiserver-1.16.tar
    $ sudo docker load -i kube-scheduler-1.16.tar
    $ sudo docker load -i kube-controller-manager-1.16.tar 
    $ sudo docker load -i kube-proxy-1.16.tar
    $ sudo docker load -i etcd-1.16.tar
    $ sudo docker load -i coredns-1.16.tar
    $ sudo docker load -i pause-1.16.tar
    ```
    ```bash
    $ sudo docker tag k8s.gcr.io/kube-apiserver:v1.16.15 ${REGISTRY}/k8s.gcr.io/kube-apiserver:v1.16.15
    $ sudo docker tag k8s.gcr.io/kube-proxy:v1.16.15 ${REGISTRY}/k8s.gcr.io/kube-proxy:v1.16.15
    $ sudo docker tag k8s.gcr.io/kube-controller-manager:v1.16.15 ${REGISTRY}/k8s.gcr.io/kube-controller-manager:v1.16.15
    $ sudo docker tag k8s.gcr.io/etcd:3.3.15-0 ${REGISTRY}/k8s.gcr.io/etcd:3.3.15-0
    $ sudo docker tag k8s.gcr.io/coredns:1.6.2 ${REGISTRY}/k8s.gcr.io/coredns:1.6.2
    $ sudo docker tag k8s.gcr.io/kube-scheduler:v1.16.15 ${REGISTRY}/k8s.gcr.io/kube-scheduler:v1.16.15
    $ sudo docker tag k8s.gcr.io/pause:3.1 ${REGISTRY}/k8s.gcr.io/pause:3.1
    ```
    ```bash
    $ sudo docker push ${REGISTRY}/k8s.gcr.io/kube-apiserver:v1.16.15
    $ sudo docker push ${REGISTRY}/k8s.gcr.io/kube-proxy:v1.16.15
    $ sudo docker push ${REGISTRY}/k8s.gcr.io/kube-controller-manager:v1.16.15
    $ sudo docker push ${REGISTRY}/k8s.gcr.io/etcd:3.3.15-0
    $ sudo docker push ${REGISTRY}/k8s.gcr.io/coredns:1.6.2
    $ sudo docker push ${REGISTRY}/k8s.gcr.io/kube-scheduler:v1.16.15
    $ sudo docker push ${REGISTRY}/k8s.gcr.io/pause:3.1
    ```
    * v1.17.6 images
    ```bash
    $ sudo docker load -i kube-apiserver-1.17.tar
    $ sudo docker load -i kube-scheduler-1.17.tar
    $ sudo docker load -i kube-controller-manager-1.17.tar 
    $ sudo docker load -i kube-proxy-1.17.tar
    $ sudo docker load -i etcd-1.17.tar
    $ sudo docker load -i coredns-1.17.tar
    $ sudo docker load -i pause-1.17.tar
    ```
    ```bash
    $ sudo docker tag k8s.gcr.io/kube-apiserver:v1.17.6 ${REGISTRY}/k8s.gcr.io/kube-apiserver:v1.17.6
    $ sudo docker tag k8s.gcr.io/kube-proxy:v1.17.6 ${REGISTRY}/k8s.gcr.io/kube-proxy:v1.17.6
    $ sudo docker tag k8s.gcr.io/kube-controller-manager:v1.17.6 ${REGISTRY}/k8s.gcr.io/kube-controller-manager:v1.17.6
    $ sudo docker tag k8s.gcr.io/etcd:3.4.3-0 ${REGISTRY}/k8s.gcr.io/etcd:3.4.3-0
    $ sudo docker tag k8s.gcr.io/coredns:1.6.5 ${REGISTRY}/k8s.gcr.io/coredns:1.6.5
    $ sudo docker tag k8s.gcr.io/kube-scheduler:v1.17.6 ${REGISTRY}/k8s.gcr.io/kube-scheduler:v1.17.6
    $ sudo docker tag k8s.gcr.io/pause:3.1 ${REGISTRY}/k8s.gcr.io/pause:3.1
    ```
    ```bash
    $ sudo docker push ${REGISTRY}/k8s.gcr.io/kube-apiserver:v1.17.6
    $ sudo docker push ${REGISTRY}/k8s.gcr.io/kube-proxy:v1.17.6
    $ sudo docker push ${REGISTRY}/k8s.gcr.io/kube-controller-manager:v1.17.6
    $ sudo docker push ${REGISTRY}/k8s.gcr.io/etcd:3.4.3-0
    $ sudo docker push ${REGISTRY}/k8s.gcr.io/coredns:1.6.5
    $ sudo docker push ${REGISTRY}/k8s.gcr.io/kube-scheduler:v1.17.6
    $ sudo docker push ${REGISTRY}/k8s.gcr.io/pause:3.1
    ```    

## Steps
0. [master upgrade](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/K8S_Master/KUBE_VERSION_UPGRADE_README.md#step0-kubernetes-master-upgrade)
1. [node upgrade](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/K8S_Master/KUBE_VERSION_UPGRADE_README.md#step1-kubernetes-node-upgrade)

## Step0. kubernetes master upgrade
* master에서 kubeadm을 upgrade 한다.
	```bash
	yum install -y kubeadm-설치버전 --disableexcludes=kubernetes
	
	ex) yum install -y kubeadm-1.16.0-0 --disableexcludes=kubernetes
	
	ex) yum install -y kubeadm-1.17.6-0 --disableexcludes=kubernetes
	```
* 버전 확인
	```bash
	kubeadm version
	```
* node drain
   * node drain 전 체크 사항
     * PDB가 존재하는 Pod가 drain하려는 node에 생성되어있는 경우 evict가 제한 되기 때문에, 아래 명령어로 drain이 가능한 상태인지 확인한다.
      ```bash
       kubectl get pdb -A
       or
       kubectl get pdb <pdb-name> -oyaml
      ```
     * ALLOWED DISRUPTIONS 및 drain 시키려는 node의 pod 상태를 확인한다.
        * PDB의 ALLOWED DISRUPTIONS가 drain을 시도하는 node에 뜬 pod(pdb 설정 pod) 개수보다 적을 경우 아래와 같이 다른 노드로 재스케줄링이 필요하다.
	   * ex) virt-api pod가 drain하려는 node에 2개 떠있는데, ALLOWED DISRUPTIONS는 0 또는 1일 경우 
        * 해당 조건에 만족하지 않는 경우 'Cannot evict pod as it would violate the pod's disruption budget' 와 같은 에러가 발생할 수 있다.
     * 해결 방법       
        * 1) 해당 Pod를 다른 Node로 재스케줄링을 시도한다.
        ```bash
        kubectl delete pod <pod-name>
        ```
       * 2) 다른 Node의 리소스 부족, noScheduling 설정 등으로 인해 a번 재스케줄링이 불가할 경우엔 PDB 데이터를 삭제하고 drain한 후에 PDB 데이터를 복구한다.
       ```bash
       kubectl get pdb <pdb-name> -o yaml > pdb-backup.yaml
       kubectl drain <node-to-drain> --ignore-daemonsets --delete-local-data
       kubectl apply -f pdb-backup.yaml
       ```
   * node drain 실행
     * warning: node drain시 해당 node상의 pod가 evict되기 때문에, pod의 local-data의 경우 보존되지 않음
      ```bash
      kubectl drain <node-to-drain> --ignore-daemonsets --delete-local-data
	
      ex) kubectl drain k8s-master --ignore-daemonsets --delete-local-data
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
	[upgrade/versions] Cluster version: v1.15.3
	[upgrade/versions] kubeadm version: v1.16.0
	[upgrade/versions] Latest stable version: v1.16.0
	[upgrade/versions] Latest version in the v1.15 series: v1.16.0

	Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
	COMPONENT   CURRENT             AVAILABLE
	Kubelet     1 x v1.15.3   v1.16.0

	Upgrade to the latest version in the v1.17 series:

	COMPONENT            CURRENT   AVAILABLE
	API Server           v1.15.3   v1.16.0
	Controller Manager   v1.15.3   v1.16.0
	Scheduler            v1.15.3   v1.16.0
	Kube Proxy           v1.15.3   v1.16.0
	CoreDNS              1.6.5     1.6.7
	Etcd                 3.4.3     3.4.3-0

	You can now apply the upgrade by executing the following command:

    	kubeadm upgrade apply v1.16.0

	_____________________________________________________________________
	```
* 업그레이드 실행
	```bash
	(1.15.x-> 1.16.x) sudo kubeadm upgrade apply v1.16.x
	
	(1.16.x-> 1.17.x) sudo kubeadm upgrade apply v1.17.x
	```
	```bash
	[upgrade/config] Making sure the configuration is correct:
	[upgrade/config] Reading configuration from the cluster...
	[upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
	[preflight] Running pre-flight checks.
	[upgrade] Running cluster health checks
	[upgrade/version] You have chosen to change the cluster version to "v1.16.0"
	[upgrade/versions] Cluster version: v1.15.3
	[upgrade/versions] kubeadm version: v1.16.0
	[upgrade/confirm] Are you sure you want to proceed with the upgrade? [y/N]: y
	[upgrade/prepull] Will prepull images for components [kube-apiserver kube-controller-manager kube-scheduler etcd]
	[upgrade/prepull] Prepulling image for component etcd.
	[upgrade/prepull] Prepulling image for component kube-apiserver.
	[upgrade/prepull] Prepulling image for component kube-controller-manager.
	[upgrade/prepull] Prepulling image for component kube-scheduler.
	[apiclient] Found 1 Pods for label selector k8s-app=upgrade-prepull-kube-controller-manager
	[apiclient] Found 0 Pods for label selector k8s-app=upgrade-prepull-etcd
	[apiclient] Found 0 Pods for label selector k8s-app=upgrade-prepull-kube-scheduler
	[apiclient] Found 1 Pods for label selector k8s-app=upgrade-prepull-kube-apiserver
	[apiclient] Found 1 Pods for label selector k8s-app=upgrade-prepull-etcd
	[apiclient] Found 1 Pods for label selector k8s-app=upgrade-prepull-kube-scheduler
	[upgrade/prepull] Prepulled image for component etcd.
	[upgrade/prepull] Prepulled image for component kube-apiserver.
	[upgrade/prepull] Prepulled image for component kube-controller-manager.
	[upgrade/prepull] Prepulled image for component kube-scheduler.
	[upgrade/prepull] Successfully prepulled the images for all the control plane components
	[upgrade/apply] Upgrading your Static Pod-hosted control plane to version "v1.16.0"...
					
						......
						
	[apiclient] Found 1 Pods for label selector component=kube-scheduler
	[upgrade/staticpods] Component "kube-scheduler" upgraded successfully!
	[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
	[kubelet] Creating a ConfigMap "kubelet-config-1.16" in namespace kube-system with the configuration for the kubelets in the cluster
	[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.16" ConfigMap in the kube-system namespace
	[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
	[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
	[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
	[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
	[addons] Applied essential addon: CoreDNS
	[addons] Applied essential addon: kube-proxy

	[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.16.0". Enjoy!

	[upgrade/kubelet] Now that your control plane is upgraded, please proceed with upgrading your kubelets if you haven't already done so.
	```
* 적용된 cordon을 해제한다.
	```bash
	kubectl uncordon <cp-node-name>
	
	ex) kubectl uncordon k8s-master
	```
* master와 node에 kubelet 및 kubectl을 업그레이드한다.
	```bash
	(1.15.x-> 1.16.x) yum install -y kubelet-1.16.x-0 kubectl-1.16.x-0 --disableexcludes=kubernetes
	
	(1.16.x-> 1.17.x) yum install -y kubelet-1.17.x-0 kubectl-1.17.x-0 --disableexcludes=kubernetes
	```
* kubelet을 재시작 한다.
	```bash
	sudo systemctl daemon-reload
	sudo systemctl restart kubelet
	```
* 비고 : 
    * master 다중화 구성 클러스터 업그레이드 시에는 다음과 같은 명령어를 실행한다.
    * 첫번째 컨트롤 플레인 업그레이드 시에는 위에 step을 진행하고, 나머지 컨트롤 플레인 업그레이드 시에는 아래의 명령어를 실행한다.	
    
    * 추가된 master에서 kubeadm을 upgrade 한다.
	```bash
	yum install -y kubeadm-설치버전 --disableexcludes=kubernetes
	
	ex) yum install -y kubeadm-1.16.0-0 --disableexcludes=kubernetes
	
	ex) yum install -y kubeadm-1.17.6-0 --disableexcludes=kubernetes
	```
    * 버전 확인
	```bash
	kubeadm version
	```
   * node drain
     * 추가 컨트롤 플레인에서도 첫번째 컨트롤 플레인 node drain 전 체크 사항을 참고하여 drain 가능한 상태인지 체크한다. 
     * node drain 실행       
       * node drain시 해당 node상의 pod가 evict되기 때문에, pod의 local-data의 경우 보존되지 않음
       ```bash
       kubectl drain <node-to-drain> --ignore-daemonsets --delete-local-data
       
       ex) kubectl drain k8s-master2 --ignore-daemonsets --delete-local-data
       ```
    * 추가 컨트롤 프레인에서는 해당 명령어를 실행하지 않는다. (sudo kubeadm upgrade plan)
    * sudo kubeadm upgrade apply 명령어 대신에 sudo kubeadm upgrade node 명령어를 실행한다.
	```bash
	sudo kubeadm upgrade node
	```
	* 적용된 cordon을 해제한다.
	```bash
	kubectl uncordon <cp-node-name>
	
	ex) kubectl uncordon k8s-master2
	```
     * master와 node에 kubelet 및 kubectl을 업그레이드한다.
	```bash
	(1.15.x-> 1.16.x) yum install -y kubelet-1.16.x-0 kubectl-1.16.x-0 --disableexcludes=kubernetes
	
	(1.16.x-> 1.17.x) yum install -y kubelet-1.17.x-0 kubectl-1.17.x-0 --disableexcludes=kubernetes
	```
     * kubelet을 재시작 한다.
	```bash
	sudo systemctl daemon-reload
	sudo systemctl restart kubelet
	```
    * 업그레이드 후 노드가 ready -> not ready 상태로 바뀐 경우
      * Failed to initialize CSINode: error updating CSINode annotation: timed out waiting for the condition; caused by: the server could not find the requested resource
    ```bash
    sudo vi /var/lib/kubelet/config.yaml에 아래 옵션 추가
    
	featureGates:
          CSIMigration: false
	  
    sudo systemctl restart kubelet	   
    ```
     * 업그레이드시 runtime 변경을 하는 경우 (docker -> cri-o)
       * crio 설치는 https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/K8S_Master#step-1-cri-o-%EC%84%A4%EC%B9%98를 참조한다.
    ```bash
    sudo vi /var/lib/kubelet/kubeadm-flags.env에 옵션 변경
    
    기존 (docker) : KUBELET_KUBEADM_ARGS="--cgroup-driver=cgroupfs --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.1      
    변경 (cri-o) : KUBELET_KUBEADM_ARGS="--container-runtime=remote --container-runtime-endpoint=/var/run/crio/crio.sock"
    
    systemctl restart kubelet
    systemctl restart docker ( #docker image registry node는 systemctl restart docker 명령어를 실행한다. )
    ```
    
## Step1. kubernetes node upgrade
* 워커 노드의 업그레이드 절차는 워크로드를 실행하는 데 필요한 최소 용량을 보장하면서, 한 번에 하나의 노드 또는 한 번에 몇 개의 노드로 실행해야 한다.
* 모든 worker node에서 kubeadm을 업그레이드한다.
	```bash
	yum install -y kubeadm-설치버전 --disableexcludes=kubernetes
	
	ex) (1.15.x-> 1.16.x) yum install -y kubeadm-1.16.x-0 --disableexcludes=kubernetes
	
	ex) (1.15.x-> 1.16.x) yum install -y kubeadm-1.17.x-0 --disableexcludes=kubernetes
	```
* node drain
   * node drain 전 체크 사항
     * PDB가 존재하는 Pod가 drain하려는 node에 생성되어있는 경우 evict가 제한 되기 때문에, 아래 명령어로 drain이 가능한 상태인지 확인한다.
      ```bash
       kubectl get pdb -A
       or
       kubectl get pdb <pdb-name> -oyaml
      ```
     * ALLOWED DISRUPTIONS 및 drain 시키려는 node의 pod 상태를 확인한다.
        * PDB의 ALLOWED DISRUPTIONS가 drain을 시도하는 node에 뜬 pod(pdb 설정 pod) 개수보다 적을 경우 아래와 같이 다른 노드로 재스케줄링이 필요하다.
	   * ex) virt-api pod가 drain하려는 node에 2개 떠있는데, ALLOWED DISRUPTIONS는 0 또는 1일 경우 
        * 해당 조건에 만족하지 않는 경우 'Cannot evict pod as it would violate the pod's disruption budget' 와 같은 에러가 발생할 수 있다.
     * 해결 방법       
        * 1) 해당 Pod를 다른 Node로 재스케줄링을 시도한다.
        ```bash
        kubectl delete pod <pod-name>
        ```
        * 2) 다른 Node의 리소스 부족, noScheduling 설정 등으로 인해 a번 재스케줄링이 불가할 경우엔 PDB 데이터를 삭제하고 drain한 후에 PDB 데이터를 복구한다.
        ```bash
        kubectl get pdb <pdb-name> -o yaml > pdb-backup.yaml
        kubectl drain <node-to-drain> --ignore-daemonsets --delete-local-data
        kubectl apply -f pdb-backup.yaml
        ```
   * node drain 실행
     * warning : node drain시 해당 node상의 pod가 evict되기 때문에, pod의 local-data의 경우 보존되지 않음
      ```bash
      kubectl drain <node-to-drain> --ignore-daemonsets --delete-local-data
	
      ex) kubectl drain k8s-node --ignore-daemonsets --delete-local-data
      ``` 
* kubelet 구성 업그레이드
	```bash
	sudo kubeadm upgrade node
	```
* kubelet과 kubectl 업그레이드
	```bash
	(1.15.x-> 1.16.x) yum install -y kubelet-1.16.x-0 kubectl-1.16.x-0 --disableexcludes=kubernetes
	
	(1.16.x-> 1.17.x) yum install -y kubelet-1.17.x-0 kubectl-1.17.x-0 --disableexcludes=kubernetes
	
	sudo systemctl daemon-reload
	sudo systemctl restart kubelet	
	```
* 적용된 cordon을 해제한다.
	```bash
	kubectl uncordon <cp-node-name>
	
	ex) kubectl uncordon k8s-node
	```
* 비고 : 	
    * 1.16.x -> 1.17.x로 업그레이드시 버전에 맞추어 위에 작업을 실행한다.
    * 업그레이드 후 노드가 ready -> not ready 상태로 바뀐 경우
      * Failed to initialize CSINode: error updating CSINode annotation: timed out waiting for the condition; caused by: the server could not find the requested resource
    ```bash
    sudo vi /var/lib/kubelet/config.yaml에 아래 옵션 추가
    
	featureGates:
          CSIMigration: false
	  
    sudo systemctl restart kubelet	   
    ``` 
     * 업그레이드시 runtime 변경을 하는 경우 (docker -> cri-o)
       * crio 설치는 https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/K8S_Master#step-1-cri-o-%EC%84%A4%EC%B9%98를 참조한다.
    ```bash
    add stop kubelet command
    
    sudo vi /var/lib/kubelet/kubeadm-flags.env에 옵션 변경
    
    기존 (docker) : KUBELET_KUBEADM_ARGS="--cgroup-driver=cgroupfs --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.1      
    변경 (cri-o) : KUBELET_KUBEADM_ARGS="--container-runtime=remote --container-runtime-endpoint=/var/run/crio/crio.sock"
    
    systemctl restart kubelet
    systemctl stop docker ( #docker image registry node는 systemctl restart docker 명령어를 실행한다. )
    
    ```
