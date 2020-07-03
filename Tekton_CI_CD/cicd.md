# CI/CD 템플릿 설치 가이드

## 구성 요소 및 버전
* cicd-util ([tmaxcloudck/cicd-util:1.0.0](https://hub.docker.com/layers/tmaxcloudck/cicd-util/1.0.1/images/sha256-4ecfa45da19312d1bfb8e885773fd2c0f3228d819fa55bf620efd97318f5eddd?context=explore))
* klar ([tmaxcloudck/klar:v2.4.0](https://hub.docker.com/layers/tmaxcloudck/klar/v2.4.0/images/sha256-2d44888e728ac60c00dcfcbfbb81e96938e2d949738891ea13fd942bdba4e523?context=explore))
* s2i ([quay.io/openshift-pipeline/s2i:nightly](https://quay.io/repository/openshift-pipeline/s2i?tag=nightly&tab=tags))
* buildah ([quay.io/buildah/stable:latest](https://quay.io/repository/buildah/stable?tag=latest&tab=tags))
* apache builder image ([tmaxcloudck/s2i-apache:2.4](https://hub.docker.com/layers/tmaxcloudck/s2i-apache/2.4/images/sha256-8f48dad3910a10fdfd02cad8513fc5b500a8c8b966a8235ac752fd850a62e8df?context=explore))
* django builder image ([tmaxcloudck/s2i-django:35](https://hub.docker.com/layers/tmaxcloudck/s2i-django/35/images/sha256-eb434e2d57cf7736480b1c7b0f3510fc8199af56322994ee0a33708b627d9899?context=explore))
* nodejs builder image ([tmaxcloudck/s2i-nodejs:12](https://hub.docker.com/layers/tmaxcloudck/s2i-nodejs/12/images/sha256-92032a129667580e13fda02aaabfc34a08bf1bf6a13a06f173bf30246780cc89?context=explore))
* tomcat builder image ([tmaxcloudck/s2i-tomcat:latest](https://hub.docker.com/layers/tmaxcloudck/s2i-tomcat/latest/images/sha256-0d6a78fb6ce799cdd1e91f24b5faf8acd5a3d91fd591d3e01c6893e7c71f10f3?context=explore))
* wildfly builder image ([tmaxcloudck/s2i-wildfly:latest](https://hub.docker.com/layers/tmaxcloudck/s2i-wildfly/latest/images/sha256-5e94e04c2597d62177b149b4e5743e0a3132bb4cd01913c525ac66ba38b3bbd3?context=explore))


## Prerequisites
1. [Tekton Pipelines](./pipeline.md)

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 YAML을 준비한다.
1. 폐쇄망에서 설치하는 경우 사용하는 image repository에 CI/CD 템플릿 설치 시 필요한 이미지를 push한다.
    * 작업 디렉토리 생성 및 환경 설정
    ```bash
    mkdir -p $HOME/cicd-install
    cd $HOME/cicd-install
    ```
    * 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받는다.
    ```bash
    # CI/CD 필수 이미지 Pull
    docker pull tmaxcloudck/cicd-util:1.0.1
    docker pull tmaxcloudck/klar:v2.4.0
    docker pull quay.io/openshift-pipeline/s2i:nightly
    docker pull quay.io/buildah/stable:latest
    docker pull tmaxcloudck/s2i-apache:2.4
    docker pull tmaxcloudck/s2i-django:35
    docker pull tmaxcloudck/s2i-nodejs:12
    docker pull tmaxcloudck/s2i-tomcat:latest
    docker pull tmaxcloudck/s2i-wildfly:latest
    
    # 이미지 태그
    docker tag tmaxcloudck/cicd-util:1.0.1 cicd-util:1.0.1
    docker tag tmaxcloudck/klar:v2.4.0 klar:v2.4.0
    docker tag quay.io/openshift-pipeline/s2i:nightly s2i:nightly
    docker tag quay.io/buildah/stable:latest buildah:latest
    docker tag tmaxcloudck/s2i-apache:2.4 s2i-apache:2.4
    docker tag tmaxcloudck/s2i-django:35 s2i-django:35
    docker tag tmaxcloudck/s2i-nodejs:12 s2i-nodejs:12
    docker tag tmaxcloudck/s2i-tomcat:latest s2i-tomcat:latest
    docker tag tmaxcloudck/s2i-wildfly:latest s2i-wildfly:latest
    
    # CI/CD 필수 이미지 Save
    docker save cicd-util:1.0.1 > cicd-util_1.0.1.tar
    docker save klar:v2.4.0 > klar_v2.4.0.tar
    docker save s2i:nightly > s2i_nightly.tar
    docker save buildah:latest > buildah_latest.tar
    docker save s2i-apache:2.4 > s2i-apache_2.4.tar
    docker save s2i-django:35 > s2i-django_35.tar
    docker save s2i-nodejs:12 > s2i-nodejs_12.tar
    docker save s2i-tomcat:latest > s2i-tomcat_latest.tar
    docker save s2i-wildfly:latest > s2i-wildfly_latest.tar
    ```
    * install yaml을 다운로드한다.
    ```bash
    wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-operator/master/_catalog_museum/was/common-task/task-s2i.yaml
    wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-operator/master/_catalog_museum/was/common-task/task-scan.yaml
    wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-operator/master/_catalog_museum/was/common-task/task-deploy.yaml
    wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-operator/master/_catalog_museum/was/apache/apache-template.yaml
    wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-operator/master/_catalog_museum/was/django/django-template.yaml
    wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-operator/master/_catalog_museum/was/nodejs/nodejs-template.yaml
    wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-operator/master/_catalog_museum/was/tomcat/tomcat-template.yaml
    wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-operator/master/_catalog_museum/was/wildfly/wildfly-template.yaml
    ```

2. 폐쇄망 환경으로 전송
    ```bash
    # 생성된 파일 모두 SCP 또는 물리 매체를 통해 폐쇄망 환경으로 복사
    scp -r $HOME/cicd-install <REMOTE_SERVER>:<PATH>
    ``` 

3. 위의 과정에서 생성한 tar 파일들을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 이미지를 push한다.
    ```bash
    # 이미지 레지스트리 주소
    REGISTRY=[IP:PORT]
   
    cd <PATH> 
    
    # Load images
    docker load < cicd-util_1.0.1.tar
    docker load < klar_v2.4.0.tar
    docker load < s2i_nightly.tar
    docker load < buildah_latest.tar
    docker load < s2i-apache_2.4.tar
    docker load < s2i-django_35.tar
    docker load < s2i-nodejs_12.tar
    docker load < s2i-tomcat_latest.tar
    docker load < s2i-wildfly_latest.tar
    
    # Tag images
    docker tag cicd-util:1.0.1 $REGISTRY/cicd-util:1.0.1
    docker tag klar:v2.4.0 $REGISTRY/klar:v2.4.0
    docker tag s2i:nightly $REGISTRY/s2i:nightly
    docker tag buildah:latest $REGISTRY/buildah:latest
    docker tag s2i-apache:2.4 $REGISTRY/s2i-apache:2.4
    docker tag s2i-django:35 $REGISTRY/s2i-django:35
    docker tag s2i-nodejs:12 $REGISTRY/s2i-nodejs:12
    docker tag s2i-tomcat:latest $REGISTRY/s2i-tomcat:latest
    docker tag s2i-wildfly:latest $REGISTRY/s2i-wildfly:latest
    
    # Push images
    docker push $REGISTRY/cicd-util:1.0.1
    docker push $REGISTRY/klar:v2.4.0
    docker push $REGISTRY/s2i:nightly
    docker push $REGISTRY/buildah:latest
    docker push $REGISTRY/s2i-apache:2.4
    docker push $REGISTRY/s2i-django:35
    docker push $REGISTRY/s2i-nodejs:12
    docker push $REGISTRY/s2i-tomcat:latest
    docker push $REGISTRY/s2i-wildfly:latest
    ```

4. YAML 파일 수정 (yq 설치 후 아래 명령 실행 또는 파일 직접 수정)
    ```bash
    REGISTRY=[IP:PORT]
       
    yq w -i task-s2i.yaml 'spec.steps[0].image' $REGISTRY/cicd-util:1.0.1
    yq w -i task-s2i.yaml 'spec.steps[1].image' $REGISTRY/cicd-util:1.0.1
    yq w -i task-s2i.yaml 'spec.steps[2].image' $REGISTRY/s2i:nightly
    yq w -i task-s2i.yaml 'spec.steps[3].image' $REGISTRY/buildah:latest
    yq w -i task-s2i.yaml 'spec.steps[4].image' $REGISTRY/buildah:latest
    yq w -i task-scan.yaml 'spec.steps[0].image' $REGISTRY/klar:v2.4.0
    yq w -i task-deploy.yaml 'spec.steps[0].image' $REGISTRY/cicd-util:1.0.1
    yq w -i task-deploy.yaml 'spec.steps[1].image' $REGISTRY/cicd-util:1.0.1

    yq w -i apache-template.yaml 'objects[4].spec.tasks[0].params[0].value' $REGISTRY/s2i-apache:2.4
    yq w -i django-template.yaml 'objects[4].spec.tasks[0].params[0].value' $REGISTRY/s2i-django:35
    yq w -i nodejs-template.yaml 'objects[4].spec.tasks[0].params[0].value' $REGISTRY/s2i-nodejs:12
    yq w -i tomcat-template.yaml 'objects[4].spec.tasks[0].params[0].value' $REGISTRY/s2i-tomcat:latest
    yq w -i wildfly-template.yaml 'objects[4].spec.tasks[0].params[0].value' $REGISTRY/s2i-wildfly:latest
    ```

## Install Steps
1. [필수 Task 설치](#step-1-필수-task-설치)
2. [CI/CD 템플릿 설치](#step-2-cicd-템플릿-설치)

## Step 1. 필수 Task 설치
* 목적 : `CI/CD 템플릿에서 사용되는 ClusterTask 배포`
* 생성 순서 : 아래 command로 설치 yaml 적용
    * (외부망 연결된 환경 설치 시 실행)
    ```bash
    kubectl apply -f https://raw.githubusercontent.com/tmax-cloud/hypercloud-operator/master/_catalog_museum/was/common-task/task-s2i.yaml
    kubectl apply -f https://raw.githubusercontent.com/tmax-cloud/hypercloud-operator/master/_catalog_museum/was/common-task/task-scan.yaml
    kubectl apply -f https://raw.githubusercontent.com/tmax-cloud/hypercloud-operator/master/_catalog_museum/was/common-task/task-deploy.yaml
    ```
    * (폐쇄망 환경 설치 시 실행)
    ```bash
    kubectl apply -f task-s2i.yaml
    kubectl apply -f task-scan.yaml
    kubectl apply -f task-deploy.yaml
    ```

## Step 2. CI/CD 템플릿 설치
* 목적 : `CI/CD 템플릿 배포`
* 생성 순서 : 아래 command로 설치 yaml 적용
    * (외부망 연결된 환경 설치 시 실행)
    ```bash
    kubectl apply -f https://raw.githubusercontent.com/tmax-cloud/hypercloud-operator/master/_catalog_museum/was/apache/apache-template.yaml
    kubectl apply -f https://raw.githubusercontent.com/tmax-cloud/hypercloud-operator/master/_catalog_museum/was/django/django-template.yaml
    kubectl apply -f https://raw.githubusercontent.com/tmax-cloud/hypercloud-operator/master/_catalog_museum/was/nodejs/nodejs-template.yaml
    kubectl apply -f https://raw.githubusercontent.com/tmax-cloud/hypercloud-operator/master/_catalog_museum/was/tomcat/tomcat-template.yaml
    kubectl apply -f https://raw.githubusercontent.com/tmax-cloud/hypercloud-operator/master/_catalog_museum/was/wildfly/wildfly-template.yaml
    ```
    * (폐쇄망 환경 설치 시 실행)
    ```bash
    kubectl apply -f apache-template.yaml
    kubectl apply -f django-template.yaml
    kubectl apply -f nodejs-template.yaml
    kubectl apply -f tomcat-template.yaml
    kubectl apply -f wildfly-template.yaml
    ```
