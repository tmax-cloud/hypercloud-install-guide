

# k8s-master installer 사용법

## 구성 요소 및 버전

## Prerequisites
  * 해당 installer는 폐쇄망 기준 가이드입니다.
  * OS 설치 및 package repo를 아래 가이드에 맞춰 설치합니다.
    * https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Package#os-%EC%84%A4%EC%B9%98--package-repo-%EA%B5%AC%EC%B6%95-%EA%B0%80%EC%9D%B4%EB%93%9C
  * image registry를 아래 가이드에 맞춰 구축합니다.
    * https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Image_Registry#image-registry-%EC%84%A4%EC%B9%98-%EA%B0%80%EC%9D%B4%EB%93%9C 
  * image registry에 이미지를 push 합니다.  
    * https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/K8S_Master#%ED%8F%90%EC%87%84%EB%A7%9D-%EC%84%A4%EC%B9%98-%EA%B0%80%EC%9D%B4%EB%93%9C

## 폐쇄망 설치 가이드

## Step0. k8s.config 설정
* 목적 : `k8s 설치 진행을 위한 k8s config 설정`
* 순서 : 

#------------------------------------------------------------------
# ex : imageRegistry={IP}:{PORT}
# ex : crioVersion={crio version}
# ex : k8sVersion={kubernetes version}
# ex : apiServer={kubernetes API server ip}
# ex : podSubnet={POD_IP_POOL}/{CIDR}
# ex : calicoVersion={calico plugin version}
#------------------------------------------------------------------
#------------------------------------------------------------------
# ex : imageRegistry=172.22.5.2:5000
# ex : crioVersion=1.17
# ex : k8sVersion=1.17.6
# ex : apiServer=172.21.7.2
# ex : podSubnet=10.244.0.0/16
# ex : calicoVersion=3.13
#------------------------------------------------------------------

## Step1. installer 실행
* 목적 : `k8s 설치 진행을 위한 shell script 실행`
* 순서 : 
	```bash
  sudo ./k8s_infra_installer.sh up
	```
* 비고 :
    * k8s.config, k8s_infra_installer.sh파일과 yaml 디렉토리는 같은 디렉토리 내에에 있어야 합니다.
