
# hypercloud-install-guide

### Module (Required)
| Module | Version | Guide | 진행률(O/△/X) |
| ------ | ------ | ------ | ------ |
| CentOS 설치 & package repo | 7.7 | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Package/README.md | O |
| Image registry |  | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Image_Registry/README.md | O |
| K8s Master | v1.17.6  | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/K8S_Master/README.md | O |
| K8s Worker | v1.17.6 | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/K8S_Worker/README.md | O |
| CNI | | https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/CNI | O |
| MetalLB | v0.8.2 | https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/MetalLB | O |
| Rook Ceph | v1.3.6 | https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/rook-ceph/README.md | O |
| HyperCloud Operator | v4.1.0.13 ~ v4.1.0.40 | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/HyperCloud%20Operator/v4.1.0.13/README.md | O |
| HyperCloud Webhook | | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/HyperCloud%20Webhook/README.md | O |
| Prometheus | v2.11.0 | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Prometheus/README.md | O |
| Console | | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Console/README.md | O |
| Tekton | v0.12.1+ | https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Tekton_CI_CD | O |
| Catalog Controller |  | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/CatalogController/README.md | O |
| TemplateServiceBroker |  | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/TemplateServiceBroker/README.md | O |
| SecretWatcher |  | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/SecretWatcher/README.md | O |

### Module (Optional)
| Module | Version | Guide | 진행률(O/△/X) |
| ------ | ------ | ------ | ------ |
| NetworkAgent |  | https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/NetworkAgent | O |
| Pod_GPU plugin | | <ul><li>https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Pod_GPU%20plugin</li><li> NVIDIA Device Plugin : https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Pod_GPU%20plugin/nvidia-device-plugin/README.md</li><li> NVIDIA Pod GPU Metrics Exporter : https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Pod_GPU%20plugin/nvidia-pod-gpu-metrics-exporter/README.md</li></ul> | O |
| Istio | 1.5.1 | [installation guide](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Istio/README.md) | O |
| Kubeflow | | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Kubeflow/README.md | O |
| EFK | E(7.2.0), F(v1.4.2), K(7.2.0) | https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/EFK/README.md | O |
| Multicloud-console |  |  | X |
| Capi provider |  | https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/Capi/README.md | O |
| NGINX Ingress Controller | 0.33.0 | https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/IngressNginx/system | O |
| kubefed |  | https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/Fed/README.md | O |
| Grafana |  | https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/Grafana/README.md | O |
| Helm |  | https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/Helm/README.md | O |
| HelmRepository |  | https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/HelmRepository/README.md | O |

### VM_Module (Optional)
| Module | Version | Guide | 진행률(O/△/X) |
| ------ | ------ | ------ | ------ |
| KubeVirt | v0.27.0 | https://github.com/tmax-cloud/hypercloud-install-guide/tree/4.1/VM_KubeVirt | O |
| CDI | v1.18.0 | https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/VM_KubeVirt/cdi/README.md | O |
| ImageController | | https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/VM_KubeVirt/Image%20Controller/README.md | △ |
| FailoverController | | https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/VM_KubeVirt/Failover%20Controller/README.md | O |
| Exporter | | https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/VM_KubeVirt/Exporter/README.md | △ |
| GPU Plugin | | https://github.com/tmax-cloud/hypercloud-install-guide/tree/4.1/VM_KubeVirt/GPU%20plugin | O |

* infra 설치
- k8s : https://docs.google.com/document/d/1bWnmyP7RPUtJQKCRdojoDj1miuLKom9WBoCfbFpI_9M/edit
- plugin : https://docs.google.com/document/d/1djT5_AvczsncN1xBq0foxXZkuTf53nAkbT2VYjc5AwI/edit
