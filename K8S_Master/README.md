
# k8s-master 설치 가이드

## 구성 요소 및 버전
* docker.io/k8s.gcr.io/kube-apiserver:v1.17.6
* docker.io/k8s.gcr.io/kube-proxy:v1.17.6
* docker.io/k8s.gcr.io/kube-scheduler:v1.17.6
* docker.io/k8s.gcr.io/kube-controller-manager:v1.17.6
* docker.io/k8s.gcr.io/etcd:3.4.3-0
* docker.io/k8s.gcr.io/pause:3.1
* docker.io/k8s.gcr.io/coredns:1.6.5

## Prerequisites

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 tar 파일을 준비한다.
1. **폐쇄망에서 설치하는 경우** 사용하는 image repository에 k8s 설치 시 필요한 이미지를 push한다. 

    * 작업 디렉토리 생성 및 환경 설정
    ```bash
    $ mkdir -p ~/k8s-install
    $ export K8S_HOME=~/k8s-install
    $ cd $K8S_HOME
    ```
    * 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받는다.
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
    ```bash
    $ docker save -o kube-proxy.tar k8s.gcr.io/kube-proxy:v1.17.6
    $ docker save -o kube-controller-manager.tar k8s.gcr.io/kube-controller-manager:v1.17.6
    $ docker save -o etcd.tar docker.io/k8s.gcr.io/etcd
    $ docker save -o coredns.tar k8s.gcr.io/coredns:1.6.5
    $ docker save -o kube-scheduler.tar k8s.gcr.io/kube-scheduler:v1.17.6
    $ docker save -o kube-apiserver.tar k8s.gcr.io/kube-apiserver:v1.17.6
    $ docker save -o pause.tar k8s.gcr.io/pause:3.1
    ```
  
2. 위의 과정에서 생성한 tar 파일들을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 이미지를 push한다.
    ```bash
    $ sudo docker load -i kube-apiserver.tar
    $ sudo docker load -i kube-scheduler.tar
    $ sudo docker load -i kube-controller-manager.tar 
    $ sudo docker load -i kube-proxy.tar
    $ sudo docker load -i etcd.tar
    $ sudo docker load -i coredns.tar
    $ sudo docker load -i pause.tar
    
    $ docker tag k8s.gcr.io/kube-apiserver:v1.17.6 ${REGISTRY}/k8s.gcr.io/kube-apiserver:v1.17.6
    $ docker tag k8s.gcr.io/kube-proxy:v1.17.6 ${REGISTRY}/k8s.gcr.io/kube-proxy:v1.17.6
    $ docker tag k8s.gcr.io/kube-controller-manager:v1.17.6 ${REGISTRY}/k8s.gcr.io/kube-controller-manager:v1.17.6
    $ docker tag k8s.gcr.io/etcd:3.4.3-0 ${REGISTRY}/k8s.gcr.io/etcd:3.4.3-0
    $ docker tag k8s.gcr.io/coredns:1.6.5 ${REGISTRY}/k8s.gcr.io/coredns:1.6.5
    $ docker tag k8s.gcr.io/kube-scheduler:v1.17.6 ${REGISTRY}/k8s.gcr.io/kube-scheduler:v1.17.6
    $ docker tag k8s.gcr.io/pause:3.1 ${REGISTRY}/k8s.gcr.io/pause:3.1

    $ docker push ${REGISTRY}/k8s.gcr.io/kube-apiserver:v1.17.6
    $ docker push ${REGISTRY}/k8s.gcr.io/kube-proxy:v1.17.6
    $ docker push ${REGISTRY}/k8s.gcr.io/kube-controller-manager:v1.17.6
    $ docker push ${REGISTRY}/k8s.gcr.io/etcd:3.4.3-0
    $ docker push ${REGISTRY}/k8s.gcr.io/coredns:1.6.5
    $ docker push ${REGISTRY}/k8s.gcr.io/kube-scheduler:v1.17.6
    $ docker push ${REGISTRY}/k8s.gcr.io/pause:3.1
    ```

## Install Steps
0. [환경 설정](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Istio#step0-istio-yaml-%EC%88%98%EC%A0%95)
1. [cri-o 설치](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Istio#step-1-istio-namespace-%EB%B0%8F-customresourcedefinition-%EC%83%9D%EC%84%B1)
2. [kubeadm, kubelet, kubectl 설치](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Istio#step-2-kiali-%EC%84%A4%EC%B9%98)
3. [kubernetes cluster 구성](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Istio#step-3-istio-tracing-%EC%84%A4%EC%B9%98)


## Step0. 환경 설정
* 목적 : `k8s 설치 진행을 위한 os 환경 설정`
* 순서 : 
    * os hostname을 설정한다.
	```bash
	hostnamectl set-hostname k8s-master
	```
    * /etc/hosts에 hostname과 ip를 등록한다. 
	```bash
	127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
	::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

	172.22.5.2 k8s-master
	```
    * 방화벽(firewall)을 해제한다. 
	```bash
	systemctl stop firewalld
	systemctl disable firewalld
	```	
    * 스왑 메모리를 비활성화 한다. 
	```bash
	swapoff -a
	```
    * 스왑 메모리 비활성화 영구설정(/etc/fstap). 
	```bash
	swap 관련 부분 주석처리
	# /dev/mapper/centos-swap swap                    swap    defaults        0
	```	
    * SELinux 설정을 해제한다. 
	```bash
	setenforce 0
	sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
	```

## Step 1. cri-o 설치
* 목적 : `k8s container runtime 설치`
* 순서 :
    * cri-o를 설치한다.
	```bash
	sudo yum -y install cri-o
	systemctl enable crio
	systemctl start crio
	```
    * cri-o 설치를 확인한다.
	```bash
	systemctl status crio
	rpm -qi cri-o
	```
* 비고 :
    * 추후 설치예정인 network plugin과 crio의 가상 인터페이스 충돌을 막기위해 cri-o의 default 인터페이스 설정을 제거한다.
	```bash
	rm -rf  /etc/cni/net.d/100-crio-bridge
 	rm -rf  /etc/cni/net.d/200-loopback
	``` 
    * 폐쇄망 환경에서 private registry 접근을 위해 crio.conf 내용을 수정한다. (/etc/crio/crio.conf)
	```bash
	insecure_registry 와 registries에 image_docker_registries_ip:port 추가
	registries = [“172.22.5.2:5000(레지스트리 주소:포트)”,”docker.io”]
	insecure_registries=[“172.22.5.2:5000(레지스트리 주소:포트)”]
	plugin_dirs에 "/opt/cni/bin" 추가
	!!!!!!!!!!!수정해야댐!!!!!!!!!!!!!!!!!
	```
    * crio 사용 전 환경 설정
	```bash
	modprobe overlay
	modprobe br_netfilter
	
	cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
	net.bridge.bridge-nf-call-iptables  = 1
	net.ipv4.ip_forward                 = 1
	net.bridge.bridge-nf-call-ip6tables = 1
	EOF
	```	
    * cri-o를 재시작 한다.
	```bash
	systemctl restart crio
	``` 	
## Step 2. kubeadm, kubelet, kubectl 설치
* 목적 : `Kubernetes 구성을 위한 kubeadm, kubelet, kubectl 설치한다.`
* 순서:
    * CRI-O 메이저와 마이너 버전은 쿠버네티스 메이저와 마이너 버전이 일치해야 한다.
    * kubeadm, kubectl, kubelet 설치 (v1.17.6)
	```bash
	yum install -y kubeadm-1.17.6-0 kubelet-1.17.6-0 kubectl-1.17.6-0
	```  	
* 비고 :
    * kiali에 접속하기 위한 서비스를 [원하는 타입](yaml/2.kiali.yaml#L346)으로 변경할 수 있다.
    * kiali에 접속하기 위한 [id/password](yaml/2.kiali.yaml#L215)를 configmap을 수정해 변경할 수 있다.(default: admin/admin)
    * kilai pod가 running임을 확인한 뒤 http://$KIALI_URL/kiali 에 접속해 정상 동작을 확인한다.
	
![image](figure/kiali-ui.png)



## Step 3. kubernetes cluster 구성
* 목적 : `kubernetes master를 구축한다.`
* 순서 :
    * 쿠버네티스 설치시 필요한 kubeadm-config를 작성한다.(kubeadm-config.yaml)
	```bash
	apiVersion: kubeadm.k8s.io/v1beta2
	kind: InitConfiguration
	localAPIEndpoint:
  		advertiseAddress: 172.22.5.2
  		bindPort: 6443
	nodeRegistration:
  		criSocket: /var/run/crio/crio.sock
	---
	apiVersion: kubeadm.k8s.io/v1beta2
	kind: ClusterConfiguration
	kubernetesVersion: v1.17.6
	controlPlaneEndpoint: 172.22.5.2:6443
	imageRepository: “172.22.5.2:5000/tmaxcloudck”
	networking:
 		serviceSubnet: 10.96.0.0/16
  		podSubnet: "10.244.0.0/16"
	---
	apiVersion: kubelet.config.k8s.io/v1beta1
	kind: KubeletConfiguration
	cgroupDriver: systemd

	```
    * kubeadm init
	```bash
	kubeadm init --config=kubeadm-config.yaml
	```
    * kubeadm init
	```bash
	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config
	```	
* 비고 : 
    * jaeger ui에 접속하기 위한 서비스를 [원하는 타입](yaml/3.istio-tracing.yaml#L245)으로 변경할 수 있다.
    * istio-tracing pod가 running임을 확인한 뒤 http://$JAEGER_URL/jaeger/search 에 접속해 정상 동작을 확인한다.
	
![image](figure/jaeger-ui.png)




## Step 4. istiod 설치
* 목적 : `istio core component 설치(istiod deployment, sidecar configmap, mutatingwebhookconfiguration...)`
* 생성 순서 : [4.istio-core.yaml](yaml/4.istio-core.yaml) 실행
* 비고 : 
    * [istio라는 이름의 configmap](yaml/4.istio-core.yaml#L403)을 수정하여 설정을 변경할 수 있다. 관련 설정은 [istio mesh config](https://istio.io/docs/reference/config/istio.mesh.v1alpha1/#MeshConfig)를 참고한다.
        * access log format을 변경하고 싶은 경우 [mesh.accessLogFormat](yaml/4.istio-core.yaml#L468)을 원하는 format으로 변경한다.
        * tracing sampling rate을 변경하고 싶은 경우 [value.traceSampling](yaml/4.istio-core.yaml#L459)을 원하는 값으로 변경한다.





## Step 5. istio-ingressgateway 설치
* 목적 : `istio ingressgateway 설치`
* 생성 순서 : [5.istio-ingressgateway.yaml](yaml/5.istio-ingressgateway.yaml) 실행




## Step 6. istio metric prometheus에 등록
* 목적 : `istio metric을 수집하기 위한 podmonitor 생성`
* 생성 순서 : [6.istio-metric.yaml](yaml/6.istio-metric.yaml) 실행
* 비고 : 
    * http://$PROMETHEUS_URL/graph 에 접속해 'envoy_'로 시작하는 istio 관련 metric이 수집되었는지 확인한다.
    * 만약 istio 관련 metric이 수집되지 않을 경우, Prometheus의 권한설정 문제일 수 있다. [prometheus-clusterRole.yaml](../Prometheus/manifests/prometheus-clusterRole.yaml)을 적용하거나 Prometheus를 최신 버전으로 설치한다.





## Step 7. bookinfo 예제
* 목적 : `istio 설치 검증을 위한 bookinfo 예제`
* 생성 순서 : [bookinfo.yaml](yaml/bookinfo.yaml) 실행
* 비고 : 
    * bookinfo 예제 배포
        * application에 접속하기 위해 [service productpage의 타입](yaml/bookinfo.yaml#L278)을 NodePort/LoadBalancer로 변경한다.
        * bookinfo 예제를 배포할 namespace에 istio-injected=enabled label을 추가한 뒤, bookinfo 예제를 배포한다. 
        ```bash
        $ kubectl label namespace $YOUR_NAMESPACE istio-injection=enabled
        $ kubectl apply -f bookinfo.yaml -n $YOUR_NAMESPACE
        ```
    * http://$PRODUCTPAGE_URL/productpage 에 접속해 정상적으로 배포되었는지 확인한 뒤, kiali dashboard(http://$KIALI_URL/kiali)에 접속해 아래 그림과 같이 서비스간에 관계를 표현해주는 그래프가 나오는지 확인한다.
	
![image](figure/bookinfo-example.png)
