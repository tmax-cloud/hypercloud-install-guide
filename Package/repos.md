
# local repository에 packages 추가 가이드

## Prerequisites
* localrepo 구축이 완료된 상황
* local repo 구축 방법 (https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Package#step-1-local-repository-%EA%B5%AC%EC%B6%95)

## 폐쇄망 설치 가이드
1. 원하는 packages를 local repo 경로에 추가
    * 추가하고자 하는 packages를 local repo 경로에 추가
	    * mv {packages} {local repo 경로}		 

    * 예시 ( kubernetes-v1.16 )    
    	    
	    * kubernetes-v1.16 다운로드 (ck-ftp@192.168.1.150:/home/ck-ftp/k8s_pl/install/offline/k8s-upgrade/1.16.15)  		
	    * scp -r ck-ftp@192.168.1.150:/home/ck-ftp/k8s_pl/install/offline/k8s-upgrade/1.16.15 . 		
	    * mv 1.16.15/*.rpm /tmp/localrepo
    
    * 예시 ( kubernetes-v1.17 )
    
    	    * kubernetes-v1.17 다운로드 (ck-ftp@192.168.1.150:/home/ck-ftp/k8s_pl/install/offline/k8s-upgrade/1.17.6)  		
	    * scp -r ck-ftp@192.168.1.150:/home/ck-ftp/k8s_pl/install/offline/k8s-upgrade/1.17.6 . 		
	    * mv 1.17.6/*.rpm /tmp/localrepo 
	    
2. local Repository 구축
    * yum repository 구축
	    * sudo createrepo {repository 경로}	    
    * 예시
	    * sudo createrepo /tmp/localrepo
	    * yum clean all && yum repolist
