# HyperCloud 5 Install Guide Navigator

### Module (Required)
| Module                            | Version                                                         | URL                                                              |
| --------------------------------- | --------------------------------------------------------------- | ---------------------------------------------------------------- |
| OS & Packages                     | ProLinux                                                        | https://github.com/tmax-cloud/install-pkg-repo/tree/5.0          |
| External DNS                      |                                                                 |                                                                  |
| Podman                            |                                                                 |                                                                  |
| Image Registry - Docker           | v2                                                              | https://github.com/tmax-cloud/install-registry/tree/5.0          |
| Image Registry - HyperRegistry    |                                                                 | https://github.com/tmax-cloud/HyperRegistry-Chart/tree/5.0       |
| Kubernetes & CRI-O                | 1.19.1, 1.19.4                                                  | https://github.com/tmax-cloud/install-k8s/tree/5.0               |
| CNI - Calico                      | 3.16.6                                                          | https://github.com/tmax-cloud/install-cni/tree/5.0               |
| CSI - NFS                         |                                                                 |                                                                  |
| CSI - Ceph                        |                                                                 |                                                                  |
| Cert Manager                      |                                                                 |                                                                  |
| Ingress Controller - nginx        | 0.33.0                                                          | https://github.com/tmax-cloud/install-ingress/tree/5.0           |
| GitLab                            |                                                                 | https://github.com/tmax-cloud/install-gitlab                     |
| Helm Operator                     |                                                                 | https://github.com/tmax-cloud/install-helm-operator/tree/5.0     |
| Prometheus                        | v2.11.0                                                         | https://github.com/tmax-cloud/install-prometheus/tree/5.0        |
| HyperAuth                         | b1.1.0.23                                                       | https://github.com/tmax-cloud/install-hyperauth/tree/5.0         |
| HyperCloud 5 API Server, Operator | v5.0.2.0, v5.0.2.0                                              | https://github.com/tmax-cloud/install-hypercloud/tree/5.0        |
| HyperCloud Console, Operator      | 0.5.1.32, 5.1.0.1                                               | https://github.com/tmax-cloud/install-console/tree/5.0           |

### Module (Recommended)
| Module                            | Version                                                         | URL                                                              |
| --------------------------------- | --------------------------------------------------------------- | ---------------------------------------------------------------- |
| Tekton CI/CD                      | Pipeline: v0.22.0<br>Trigger: v0.12.1<br>CI/CD Operator: v0.4.2 | https://github.com/tmax-cloud/install-tekton/tree/5.0            |
| Catalog Controller                | v0.3.0                                                          | https://github.com/tmax-cloud/install-catalog/tree/5.0           |
| Template ServiceBroker            | 0.0.8                                                           | https://github.com/tmax-cloud/install-tsb/tree/tsb-5.0           |
| MetalLB                           | v0.9.3                                                          | https://github.com/tmax-cloud/install-metallb/tree/5.0           |
| Registry Operator                 | v0.3.1                                                          | https://github.com/tmax-cloud/install-registry-operator/tree/5.0 |
| CAPI                              | v0.3.6                                                          | https://github.com/tmax-cloud/install-capi/tree/5.0              |
| KubeFed                           | v0.3.0                                                          | https://github.com/tmax-cloud/install-federation/tree/5.0        |
| AWX Operator                      |                                                                 |                                                                  |

### Module (Optional)
| Module                   | Version              | Guide                                                                   |
| ------------------------ | -------------------- | ----------------------------------------------------------------------- |
| Grafana                  | 6.4.3                | https://github.com/tmax-cloud/install-grafana/tree/5.0                  |
| Istio                    | v1.5.1               | https://github.com/tmax-cloud/install-istio/tree/5.0                    |
| Kiali                    | 1.21                 | https://github.com/tmax-cloud/install-kiali/tree/5.0                    |
| NetworkAgent             | v0.4.2               | https://github.com/tmax-cloud/install-networkagent/tree/5.0             |
| NetworkWebhook           | 0.1.3                | https://github.com/tmax-cloud/install-networkwebhook/tree/4.1           |
| Nvidia GPU               |                      | https://github.com/tmax-cloud/install-nvidia-gpu-infra/tree/5.0         |
| KubeFlow                 | v1.0.2               | https://github.com/tmax-cloud/install-ai-devops/tree/main               |
| EFK                      | 7.2.0, v1.4.2, 7.2.0 | https://github.com/tmax-cloud/install-EFK/tree/5.0                      |
| Helm                     | v3                   | https://github.com/tmax-cloud/install-helm/tree/master                  |
| ChartMuseum              |                      | https://github.com/tmax-cloud/install-helm-repository/tree/master       |
| ovirt                    | 4.4.3                | https://github.com/tmax-cloud/install-ovirt/tree/main                   |
| OLM                      | 0.15.1               | https://github.com/tmax-cloud/install-OLM/tree/main                     |
| clair                    | ???                  | https://github.com/tmax-cloud/install_clair/tree/main                   |
| velero                   | 1.4.2                | https://github.com/tmax-cloud/install-velero/tree/main                  |
| CAPI-provider-aws        | v0.5.5-alpha.0       | https://github.com/tmax-cloud/install-CAPI/tree/5.0                     |
| registry-operator        | v0.3.1               | https://github.com/tmax-cloud/install-registry-operator/tree/5.0        |
| image-validating-webhook | ???                  | https://github.com/tmax-cloud/install-image-validating-webhook/tree/5.0 |
| HAProxy & Keepalived     | 1.5.18, 1.3.5        | https://github.com/tmax-cloud/install-haproxy/tree/5.0 |
