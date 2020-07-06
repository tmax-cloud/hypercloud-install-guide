# hypercloud-install-guide

### Module

| Module | Version | Guide |
| ------ | ------ | ------ |
| Kubernetes | | [installation guide](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Kubernetes/README.md) |
| CNI | | https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/CNI |
| MetalLB | | https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/MetalLB |
| NetworkAgent | | https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/NetworkAgent |
| Rook Ceph | | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Rook%20Ceph/README.md |
| KubeVirt | | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/KubeVirt/README.md |
| HyperCloud Operator | | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/HyperCloud%20Operator/README.md |
| Console | | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Console/README.md |
| Prometheus | | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Prometheus/README.md |
| Istio | | [installation guide](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/istio/README.md) |
| Kubeflow | | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Kubeflow/README.md |
| Pod_GPU plugin | | <ul><li>https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Pod_GPU%20plugin</li><li> NVIDIA Device Plugin : https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Pod_GPU%20plugin/NVIDIA%20Device%20Plugin/README.md</li><li> Monitoring : https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Pod_GPU%20plugin/Monitoring/README.md</li></ul> |

### VM_Module (Optional)
| Module | Version | Guide |
| ------ | ------ | ------ |
| KubeVirt | | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/KubeVirt/README.md |
| CDI | | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/VM_KubeVirt/CDI/README.md |
| ImageController | | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/VM_KubeVirt/Image%20Controller/README.md |
| FailoverController | | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/VM_KubeVirt/Failover%20Controller/README.md |
| Exporter | | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/VM_KubeVirt/Exporter/README.md |
| GPU Plugin | | https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/VM_KubeVirt/GPU%20plugin |

* OS 설치 & package repo    R
* Image registry            R (updating)
* K8s Master                R (updating)
* K8s Worker    R (updating)
* CNI           R
* Rook-Ceph     R
* Prometheus    R
* Teckton
* TemplateServiceBroker
* SecretWatcher
* WebhookServer
* Hypercloud operator
* Console

* MetalLB   O
* Network Agent O
* VM KubeVirt  O (updating)
* VM CDI       O (updating)
* VM ImageController   O (updating)
* VM FailoverController   O (updating)
* VM GPU Plugin O (updating)
* VM Exporter   O (updating)
* nVidia GPU Plugin   O (updating)
* Istio     O
* Kubeflow  O
* Multicloud-console  O
* Capi provider O
* nginx-ingress controller O
* kubefed O
* efk   O
