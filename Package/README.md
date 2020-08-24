
# OS 설치 & package repo 구축 가이드

## 구성 요소 및 버전
* HyperCloud 패키지(ck-ftp@192.168.1.150:/home/ck-ftp/k8s_pl/install/offline/archive_20.07.10)
* ISO 파일(CentOS 7.7 :http://vault.centos.org/7.7.1908/isos/x86_64/ 또는 http://192.168.2.136/ISOs/CentOS-7-x86_64-DVD-1908.iso)

## Prerequisites
* ceph 설치 시 주의사항 참고 (https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Package/warning.md)
## 폐쇄망 설치 가이드
1. Install OS
    * CentOS 7.7 설치
	    * 해당 환경에 맞게 OS를 설치합니다. (IP, hostname, software selection 등)		* 

2. Repository 구축
    * HyperCloud 용 yum repository 구축
	    * HyperCloud 설치 시 필요한 패키지들로 yum Reposiroty 구축		*  

## Install Steps
0. [Install OS](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Package/README.md#step-0-install-os)
1. [Create Local Repository](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Package/README.md#step-1-local-repository-%EA%B5%AC%EC%B6%95)


## Step 0. Install OS
* 목적 : `CentOS 7.7 설치`
* 생성 순서 : 
    * IP 설정 및 hostname 설정
	    * Network & Host name 클릭
		    ![ip-config1](https://user-images.githubusercontent.com/45585638/86681526-9f366600-c03a-11ea-9717-f3fa29e98f3b.png)
      * Configure 클릭
        ![ip-config2](https://user-images.githubusercontent.com/45585638/86681543-a3628380-c03a-11ea-8af4-95a769c87cb4.png)
      * IPv4 Setting 클릭 후 해당 환경에 맞게 IP 설정
        ![ip-config3](https://user-images.githubusercontent.com/45585638/86681549-a52c4700-c03a-11ea-9058-3a4eb56d676f.png)
      * Network 설정 활성화
        ![ip-config4](https://user-images.githubusercontent.com/45585638/86681561-a8273780-c03a-11ea-8532-6d6788dee8fe.png)
      * Hostname 설정 후 Apply
        ![hostname-config1](https://user-images.githubusercontent.com/45585638/86681572-a9f0fb00-c03a-11ea-9b68-f75df69a8c4c.png)
      * Begin Installation 이후 설치 진행
        
* 비고 :
    * CentOS 설치 자체보다 hypercloud 설치할 때 필요한 부분만 언급하였습니다.    

## Step 1. Local Repository 구축
* 목적 : `폐쇄망일 때 yum repository 구축`
* 생성 순서 : 
    * 패키지 가져오기
      * scp -r ck-ftp@192.168.1.150:/home/ck-ftp/k8s_pl/install/offline/archive_20.07.10 .
      * cp -rT ./archive_20.07.10 /tmp/localrepo
    * CentOS Repository 비활성화
      * sudo vi /etc/yum.repos.d/CentOS-Base.repo
      * [base], [updates], [extra] repo config 에 enabled=0 추가
      * ![repo-config1](https://user-images.githubusercontent.com/45585638/86690147-9f3a6400-c042-11ea-85a6-b9df49c76e66.png)
    * Yum Repository 구축
      * sudo yum install -y /tmp/localrepo/createrepo/*.rpm
      * sudo createrepo /tmp/localrepo
      * sudo cat << "EOF" | sudo tee -a /etc/yum.repos.d/localrepo.repo
      * [localrepo]
      * name=localrepo
      * baseurl=file:///tmp/localrepo/
      * enabled=1
      * gpgcheck=0
      * EOF
    * 확인
      * sudo yum clean all && yum repolist
      * 다음과 같이 나오면 완료.
      * ![repo-config3](https://user-images.githubusercontent.com/45585638/87265534-fedeb680-c4fd-11ea-80f8-2bb74fa530f1.png)
