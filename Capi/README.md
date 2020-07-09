
# Capi 설치 가이드

## 구성 요소 및 버전
* Cluster Api([github.com/kubernetes-sigs/cluster-api/v0.3.6](https://github.com/kubernetes-sigs/cluster-api/releases/tag/v0.3.6))
* InfrastructureProvider-AWS ([https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/tag/v0.5.5-alpha.0](https://github.com/kubernetes-sigs/cluster-api/releases/tag/v0.5.5-alpha.0))

## Prerequisites
* kubernetes version >= 1.16
* AWS IAM 정보.

## 폐쇄망 설치 가이드
"Step 0. Capi/infraProvider -  _폐쇄망 작업_" 추가 실행.

## Install Steps
0. [Capi/infraProvider 설정]
1. [Capi/infraProvider 구축](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Capi#step-1-capiinfraprovider-%EA%B5%AC%EC%B6%95)
2. [CapiCluster 생성](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Capi#step-1-capiinfraprovider-%EA%B5%AC%EC%B6%95)

## Step 0. Capi/infraProvider 설정
* 목적 : Capi/infraProvider 구축 전 설정.
* 생성 순서 :
    * script 실행 권한 부여
    ```bash
    $ chmod +x *.sh
    ```
    * AWS IAM 등록
    ```bash
    $ ./0.setAWS.sh
    ~~~~~~~~~~~~~~~~~~~
    ~~ AWS unzip log ~~
    ~~~~~~~~~~~~~~~~~~~
    [insert AWS IAM]
      => AWS Access Key Id: <AWS Access Key Id>
      => AWS Secret Access Key: <AWS Secret Access Key>
      => Default region name: <Default region name>
      => Default output format: <Default output format>
    ```
    * 환경 변수 등록
    ```bash
    $ vim 1.setEnv.sh ## 환경 변수를 적절히 수정
    $ source 1.setEnv.sh
    ```
    * 환경 구축에 필요한 yaml download
    ```bash
    $ ./2.1.init.sh
    ```
    * _폐쇄망 작업_
    ```bash
    $ ./2.2.setPrivate.sh
    ```

## Step 1. Capi/infraProvider 구축
* 목적 : Capi/infraProvider 구축
* 생성 순서 : 
    * Capi/infraProvider yaml 적용
    ```bash
    $ ./3.provisionCapi
    ```
## Step 2. CapiCluster 생성
* 목적 : CapiCluster 생성
* 생성 순서 :
    * CapiCluster 생성
    ```bash
    $ ./4.genCluster <cluster-name> <kubernetes-version> <number of master nodes> <number of worker nodes>
    ```
