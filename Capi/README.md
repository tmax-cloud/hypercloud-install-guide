
# Capi 설치 가이드

## 구성 요소 및 버전
* ClusterApiProvider, BootstrapProvider, ControlPlaneProvider([github.com/kubernetes-sigs/cluster-api/v0.3.6](https://github.com/kubernetes-sigs/cluster-api/releases/tag/v0.3.6))
* InfrastructureProvider-AWS ([github.com/kubernetes-sigs/cluster-api/v0.3.6](https://github.com/kubernetes-sigs/cluster-api/releases/tag/v0.3.6))

## Prerequisites
* kubernetes version >= 1.16

## 폐쇄망 설치 가이드
추후 작업 예정.

## Install Steps
0. [Binary 설치](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Capi/README.md#step-0-binary-%EC%84%A4%EC%B9%98)
1. [Capi/infraProvider 구축](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Capi#step-1-capiinfraprovider-%EA%B5%AC%EC%B6%95)
2. [CapiCluster 생성](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Capi#step-1-capiinfraprovider-%EA%B5%AC%EC%B6%95)

## Step 0. Binary 설치
* 목적 : Capi 구축에 필요한 binary 설치
* 생성 순서 : 
    * capi binary(clustercrl) 설치
      ```bash
      $ curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v0.3.3/clusterctl-linux-amd64 -o clusterctl
      $ chmod +x ./clusterctl
      $ sudo mv ./clusterctl /usr/local/bin/clusterctl
      ```
    * infraProvider binary 설치
      * AWS
        * awscli 설치
          ```bash
          $ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
          $ unzip awscliv2.zip
          $ sudo ./aws/install
          $ aws configure
            $ access key id: AKIAQDF4RKX2ZSXN25H3
            $ secret access key: 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
            $ region: us-east-1
            $ output format: json
          ```
        * clusterawsadm 설치
          ```bash
          $ curl -L https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/download/v0.5.2/clusterawsadm-linux-amd64 -o clusterawsadm
          $ chmod +x ./clusterawsadm
          $ sudo mv clusterawsadm /usr/local/bin/clusterawsadm
          ```

## Step 1. Capi/infraProvider 구축
* 목적 : Capi/infraProvider 구축
* 생성 순서 : 
    * AWS 환경변수 등록
      ```bash
      $ export AWS_REGION=us-east-1
      $ export AWS_ACCESS_KEY_ID=AKIAQDF4RKX2ZSXN25H3
      $ export AWS_SECRET_ACCESS_KEY=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
      $ clusterawsadm alpha bootstrap create-stack
      $ export AWS_B64ENCODED_CREDENTIALS=$(clusterawsadm alpha bootstrap encode-aws-credentials)
      ```
    * Capi 관련 yaml 생성
      ```bash
      $ chmod +x init.sh
      $ ./init.sh
      ```
    * Capi/infraProvider yaml 적용
      ```bash
      $ kubectl apply -f yaml/_install/1.cluster-api-components.yaml
      $ kubectl apply -f yaml/_install/2.bootstrap-components.yaml
      $ kubectl apply -f yaml/_install/3.control-plane-components.yaml
      $ kubectl apply -f yaml/_install/4.infrastructure-components-aws.yaml

## Step 2. CapiCluster 생성
* 목적 : CapiCluster 생성
* 생성 순서 :
    * CapiCluster yaml 생성
      * AWS 환경변수 등록
        ```bash
	      $ export AWS_REGION=us-east-1
	      $ export AWS_SSH_KEY_NAME=default
	      $ export AWS_CONTROL_PLANE_MACHINE_TYPE=t3.large
	      $ export AWS_NODE_MACHINE_TYPE=t3.large
        ```
      * CapiCluster yaml 생성
	      ```bash
        $ chmod +x genCluster.sh
        $ ./genCluster <cluster-name> <kubernetes-version> <number of master nodes> <number of worker nodes>
        ```
    * CapiCluster yaml 적용
      ```bash
    	$ kubectl apply -f yaml/cluster.yaml
      ```
    * 정상 동작 확인
      * CapiCluster 생성 30분 후, machine의 PHASE가 running인지 확인
      ```bash
      $ kubectl get machine
      ```
