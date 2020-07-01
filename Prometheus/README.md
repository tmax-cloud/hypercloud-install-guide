
# Prometheus 설치 가이드

## 구성 요소(prometheus-2.11.0)
* prometheus ([quay.io/prometheus/prometheus:v2.11.0](https://quay.io/repository/prometheus/prometheus?tag=latest&tab=tags))
* prometheus-operator ([quay.io/coreos/prometheus-operator:v0.34.0](https://quay.io/repository/coreos/prometheus-operator?tag=latest&tab=tags))
* node-exporter ([quay.io/prometheus/node-exporter:v0.18.1](https://quay.io/repository/prometheus/node-exporter?tag=latest&tab=tags))
* grafana ([grafana/grafana:6.4.3](https://grafana.com/grafana/download))
* kube-state-metric ([quay.io/coreos/kube-state-metrics:v1.8.0](https://quay.io/repository/coreos/kube-state-metrics?tag=latest&tab=tags))
* configmap-reloader ([quay.io/coreos/prometheus-config-reloader:v0.34.0](https://quay.io/repository/coreos/prometheus-config-reloader?tag=latest&tab=tags))
* configmap-reload ([quay.io/coreos/configmap-reload:v0.0.1](https://quay.io/repository/coreos/configmap-reload?tag=latest&tab=tags))
* kube-rbac-proxy ([quay.io/coreos/kube-rbac-proxy:v0.4.1](https://quay.io/repository/coreos/kube-rbac-proxy?tag=latest&tab=tags))
* prometheus-adapter ([quay.io/coreos/k8s-prometheus-adapter-amd64:v0.5.0](https://quay.io/repository/coreos/k8s-prometheus-adapter-amd64?tag=latest&tab=tags))
* alertmanager ([quay.io/prometheus/alertmanager:v0.20.0](https://quay.io/repository/prometheus/alertmanager?tag=latest&tab=tags))


## Prerequisite
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지를 준비한다.
* **폐쇄망에서 설치하는 경우** 사용하는 image repository에 prometheus 설치 시 필요한 이미지를 push해야함
    * 작업 디렉토리 생성 및 환경 설정
    ```
    $ mkdir -p ~/prometheus-install
    $ export PROMETHEUS_HOME=~/istio-install
    $ export PROMETHEUS_VERSION=v2.11.0
    $ export PROMETHEUS_OPERATOR_VERSION=v0.34.0
    $ export NODE_EXPORTER_VERSION=v0.18.1
	$ export GRAFANA_VERSION=6.4.3
	$ export KUBE_STATE_METRICS_VERSION=v1.8.0
	$ export CONFIGMAP_RELOADER_VERSION=v0.34.0
	$ export CONFIGMAP_RELOAD_VERSION=v0.0.1
	$ export KUBE_RBAC_PROXY_VERSION=v0.4.1
	$ export PROMETHEUS_ADAPTER_VERSION=v0.5.0
	$ export ALERTMANAGER_VERSION=v0.20.0
	$ cd $PROMETHEUS_HOME
    ```
    * 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받는다.
    ```
    $ sudo docker pull quay.io/prometheus/prometheus:${PROMETHEUS_VERSION}
    $ sudo docker save quay.io/prometheus/prometheus:${PROMETHEUS_VERSION} > prometheus-prometheus_${PROMETHEUS_VERSION}.tar
	$ sudo docker pull quay.io/coreos/prometheus-operator:${PROMETHEUS_OPERATOR_VERSION}
    $ sudo docker save quay.io/coreos/prometheus-operator:${PROMETHEUS_OPERATOR_VERSION} > prometheus-operator_${PROMETHEUS_OPERATOR_VERSION}.tar
	$ sudo docker pull quay.io/prometheus/node-exporter:${NODE_EXPORTER_VERSION}
    $ sudo docker save quay.io/prometheus/node-exporter:${NODE_EXPORTER_VERSION} > node-exporter_${NODE_EXPORTER_VERSION}.tar
	$ sudo docker pull grafana/grafana:${GRAFANA_VERSION}
    $ sudo docker save grafana/grafana:${GRAFANA_VERSION} > grafana_${GRAFANA_VERSION}.tar
	$ sudo docker pull quay.io/coreos/kube-state-metrics:${KUBE_STATE_METRICS_VERSION}
    $ sudo docker save quay.io/coreos/kube-state-metrics:${KUBE_STATE_METRICS_VERSION} > kube-state-metrics_${KUBE_STATE_METRICS_VERSION}.tar
	$ sudo docker pull quay.io/coreos/prometheus-config-reloader:${CONFIGMAP_RELOADER_VERSION}
    $ sudo docker save quay.io/coreos/prometheus-config-reloader:${CONFIGMAP_RELOADER_VERSION} > config-reloader_${CONFIGMAP_RELOADER_VERSION}.tar
	$ sudo docker pull quay.io/coreos/configmap-reload:${CONFIGMAP_RELOAD_VERSION}
    $ sudo docker save quay.io/coreos/configmap-reload:${CONFIGMAP_RELOAD_VERSION} > config-reload_${CONFIGMAP_RELOAD_VERSION}.tar
	$ sudo docker pull quay.io/coreos/kube-rbac-proxy:${KUBE_RBAC_PROXY_VERSION}
    $ sudo docker save quay.io/coreos/kube-rbac-proxy:${KUBE_RBAC_PROXY_VERSION} > kube-rbac-proxy_${KUBE_RBAC_PROXY_VERSION}.tar
	$ sudo docker pull quay.io/coreos/k8s-prometheus-adapter-amd64:${PROMETHEUS_ADAPTER_VERSION}
    $ sudo docker save quay.io/coreos/k8s-prometheus-adapter-amd64:${PROMETHEUS_ADAPTER_VERSION} > prometheus-adapter_${PROMETHEUS_ADAPTER_VERSION}.tar
	$ sudo docker pull quay.io/prometheus/alertmanager:${ALERTMANAGER_VERSION}
    $ sudo docker save quay.io/prometheus/alertmanager:${ALERTMANAGER_VERSION} > alertmanager_${ALERTMANAGER_VERSION}.tar
    ```
    * 생성한 이미지 tar 파일을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 push한다.
    ```
    $ sudo docker load < prometheus-prometheus_${PROMETHEUS_VERSION}.tar
    $ sudo docker load < prometheus-operator_${PROMETHEUS_OPERATOR_VERSION}.tar
    $ sudo docker load < node-exporter_${NODE_EXPORTER_VERSION}.tar
    $ sudo docker load < grafana_${GRAFANA_VERSION}.tar
	$ sudo docker load < kube-state-metrics_${KUBE_STATE_METRICS_VERSION}.tar
	$ sudo docker load < config-reloader_${CONFIGMAP_RELOADER_VERSION}.tar
	$ sudo docker load < config-reload_${CONFIGMAP_RELOAD_VERSION}.tar
	$ sudo docker load < kube-rbac-proxy_${KUBE_RBAC_PROXY_VERSION}.tar
	$ sudo docker load < prometheus-adapter_${PROMETHEUS_ADAPTER_VERSION}.tar
	$ sudo docker load < alertmanager_${ALERTMANAGER_VERSION}.tar
    
    $ sudo docker tag quay.io/prometheus/prometheus:${PROMETHEUS_VERSION} ${REGISTRY}/quay.io/prometheus/prometheus:${PROMETHEUS_VERSION}
    $ sudo docker tag quay.io/coreos/prometheus-operator:${PROMETHEUS_OPERATOR_VERSION} ${REGISTRY}/quay.io/coreos/prometheus-operator:${PROMETHEUS_OPERATOR_VERSION}
    $ sudo docker tag quay.io/prometheus/node-exporter:${NODE_EXPORTER_VERSION} ${REGISTRY}/quay.io/prometheus/node-exporter:${NODE_EXPORTER_VERSION}
    $ sudo docker tag grafana/grafana:${GRAFANA_VERSION} ${REGISTRY}/grafana/grafana:${GRAFANA_VERSION}
	$ sudo docker tag quay.io/coreos/kube-state-metrics:${KUBE_STATE_METRICS_VERSION} ${REGISTRY}/quay.io/coreos/kube-state-metrics:${KUBE_STATE_METRICS_VERSION}
	$ sudo docker tag quay.io/coreos/prometheus-config-reloader:${CONFIGMAP_RELOADER_VERSION} ${REGISTRY}/quay.io/coreos/prometheus-config-reloader:${CONFIGMAP_RELOADER_VERSION}
	$ sudo docker tag quay.io/coreos/configmap-reload:${CONFIGMAP_RELOAD_VERSION} ${REGISTRY}/quay.io/coreos/configmap-reload:${CONFIGMAP_RELOAD_VERSION}
	$ sudo docker tag quay.io/coreos/kube-rbac-proxy:${KUBE_RBAC_PROXY_VERSION} ${REGISTRY}/quay.io/coreos/kube-rbac-proxy:${KUBE_RBAC_PROXY_VERSION}
	$ sudo docker tag quay.io/coreos/k8s-prometheus-adapter-amd64:${PROMETHEUS_ADAPTER_VERSION} ${REGISTRY}/quay.io/coreos/k8s-prometheus-adapter-amd64:${PROMETHEUS_ADAPTER_VERSION}
	$ sudo docker tag quay.io/prometheus/alertmanager:${ALERTMANAGER_VERSION} ${REGISTRY}/quay.io/prometheus/alertmanager:${ALERTMANAGER_VERSION}
    
    $ sudo docker push ${REGISTRY}/quay.io/prometheus/prometheus:${PROMETHEUS_VERSION}
    $ sudo docker push ${REGISTRY}/quay.io/coreos/prometheus-operator:${PROMETHEUS_OPERATOR_VERSION}
    $ sudo docker push ${REGISTRY}/quay.io/prometheus/node-exporter:${NODE_EXPORTER_VERSION}
    $ sudo docker push ${REGISTRY}/grafana/grafana:${GRAFANA_VERSION}
	$ sudo docker push ${REGISTRY}/quay.io/coreos/kube-state-metrics:${KUBE_STATE_METRICS_VERSION}
	$ sudo docker push ${REGISTRY}/quay.io/coreos/prometheus-config-reloader:${CONFIGMAP_RELOADER_VERSION}
	$ sudo docker push ${REGISTRY}/quay.io/coreos/configmap-reload:${CONFIGMAP_RELOAD_VERSION}
	$ sudo docker push ${REGISTRY}/quay.io/coreos/kube-rbac-proxy:${KUBE_RBAC_PROXY_VERSION}
	$ sudo docker push ${REGISTRY}/quay.io/coreos/k8s-prometheus-adapter-amd64:${PROMETHEUS_ADAPTER_VERSION}
	$ sudo docker push ${REGISTRY}/quay.io/prometheus/alertmanager:${ALERTMANAGER_VERSION}
	
    ```


## Install Steps
1. [prometheus namespace 및 crd 생성]
2. [prometheus 설치]
3. [alertmanager 설치]
4. [grafana 설치]


***

## Step 1. prometheus namespace 및 crd 생성

***

## Step 2. prometheus 설치


***

## Step 3. istio-tracing 설치



***

## Step 4. istiod 설치



***

