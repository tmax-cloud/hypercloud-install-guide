
# Capi 설치 가이드

## 구성 요소 및 버전
* Cluster Api([github.com/kubernetes-sigs/cluster-api/latest](https://github.com/kubernetes-sigs/cluster-api/releases/latest))
* InfrastructureProvider-AWS ([https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/latest](https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/latest))

 ### **주의**
 _1. Capi는 public cloud와 원활한 통신을 위해 가급적 **최신 버전을 유지**해야 합니다. 최신 버전 확인은 위 링크를 통해 확인 바랍니다_
 <br>_2. 버전 관리 문제로 default yaml을 upload 하지 않았으나, install guide 단계 중 yaml download하는 과정이 있습니다_ 

## Prerequisites
* kubernetes version >= 1.16
* AWS IAM 정보

## 폐쇄망 설치 가이드
"Step 0. Capi/infraProvider -  _폐쇄망 작업_" 추가 실행

## Install Steps
0. [Capi/infraProvider 설정](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Capi#step-0-capiinfraprovider-%EC%84%A4%EC%A0%95)
1. [Capi/infraProvider 구축](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Capi#step-1-capiinfraprovider-%EA%B5%AC%EC%B6%95)
2. [CapiCluster 생성](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Capi#step-1-capiinfraprovider-%EA%B5%AC%EC%B6%95)

## Step 0. Capi/infraProvider 설정
* 목적 : Capi/infraProvider 구축 전 설정
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
