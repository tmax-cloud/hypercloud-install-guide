
# Kubeflow 설치 가이드

## 구성 요소 및 버전
* Kubeflow v1.0.2 (https://github.com/kubeflow/kubeflow)
* Argo v2.8 (https://github.com/argoproj/argo)
* Jupyter (https://github.com/jupyter/notebook)
* Katib v0.8.0 (https://github.com/kubeflow/katib)
* KFServing v0.4.0 (https://github.com/kubeflow/kfserving)
* Training Job
    * TFJob v1.0.0 (https://github.com/kubeflow/tf-operator)
    * PytorchJob v1.0.0 (https://github.com/kubeflow/pytorch-operator)
* ...

## Prerequisites
1. Storage class
    * 아래 명령어를 통해 storage class가 설치되어 있는지 확인한다.
        ```bash
        $ kubectl get storageclass
        ```
    * 만약 아무 storage class가 없다면 아래 링크로 이동하여 rook-ceph 설치한다.
        * https://github.com/tmax-cloud/hypercloud-install-guide/tree/4.1/rook-ceph
    * Storage class는 있지만 default로 설정된 것이 없다면 아래 명령어를 실행한다.
        ```bash
        $ kubectl patch storageclass csi-cephfs-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
        ```
    * csi-cephfs-sc는 위 링크로 rook-ceph를 설치했을 때 생성되는 storage class이며 다른 storage class를 default로 사용해도 무관하다.
2. Istio
    * v1.5.1
        * https://github.com/tmax-cloud/hypercloud-install-guide/tree/4.1/Istio
3. Prometheus
    * Kubeflow의 모니터링 정보를 제공하기 위해 필요하다.
        * https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/Prometheus/README.md
4. (Optional) GPU plug-in
    * Kubernetes cluster 내 node에 GPU가 탑재되어 있으며 AI DevOps 기능을 사용할 때 GPU가 요구될 경우에 필요하다.
        * https://github.com/tmax-cloud/hypercloud-install-guide/tree/4.1/Pod_GPU%20plugin

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. 이미지 준비
    * 아래 링크를 참고하여 폐쇄망에서 사용할 registry를 구축한다.
        * https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/Image_Registry/README.md
    * 자신이 사용할 registry의 IP와 port를 입력한다.
        ```bash
        $ export REGISTRY_ADDRESS=1.1.1.1:5000
        ```
    * 아래 명령어를 수행하여 Kubeflow 설치 시 필요한 이미지들을 위에서 구축한 registry에 push하고 이미지들을 tar 파일로 저장한다. tar 파일은 images 디렉토리에 저장된다.
        ```bash
        $ wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/4.1/Kubeflow/image-push.sh
        $ wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/4.1/Kubeflow/imagelist
        $ chmod +x ./image-push.sh
        $ ./image-push.sh ${REGISTRY_ADDRESS}
        ```
    * 아래 명령어를 수행하여 registry에 이미지들이 잘 push되었는지, 그리고 필요한 이미지들이 tar 파일로 저장되었는지 확인한다.
        ```bash
        $ curl -X GET ${REGISTRY_ADDRESS}/v2/_catalog
        $ ls ./images
        ```
    * (Optional) 만약 설치에 필요한 이미지들을 pull받아서 tar 파일로 저장하는 작업과 로드하여 push하는 작업을 따로 수행하고자 한다면 image-push.sh이 아니라 image-save.sh, image-load.sh를 각각 실행하면 된다. 
       * image-save.sh을 실행하면 설치에 필요한 이미지들을 pull 받아서 images 디렉토리에 tar 파일로 저장한다.
           ```bash
           $ wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/4.1/Kubeflow/image-save.sh
           $ chmod +x ./image-save.sh
           $ ./image-save.sh
           $ ls ./images
           ```
       * 위에서 저장한 images 디렉토리와 image-load.sh을 폐쇄망 환경으로 옮긴 후 실행하면 폐쇄망 내 구축한 registry에 이미지들을 push할 수 있다. image-load.sh은 images 디렉토리와 같은 경로에서 실행해야만 한다.
           ```bash
           $ chmod +x ./image-load.sh
           $ ./image-load.sh ${REGISTRY_ADDRESS}
           $ curl -X GET ${REGISTRY_ADDRESS}/v2/_catalog
           ```
2. Yaml 파일 및 script 파일 준비
    * 아래 명령어를 수행하여 Kubeflow 설치에 필요한 yaml 파일들과 script 파일들을 다운로드 받는다. 
        ```bash
        $ wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/4.1/Kubeflow/sed.sh
        $ wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/4.1/Kubeflow/kustomize_local.tar.gz
        $ wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/4.1/Kubeflow/kfctl_hypercloud_kubeflow.v1.0.2_local.yaml
        $ wget https://github.com/kubeflow/kfctl/releases/download/v1.0.2/kfctl_v1.0.2-0-ga476281_linux.tar.gz
        ```
3. 앞으로의 진행
    * Step 0 ~ 4 중 Step 0, 2, 3은 비고를 참고하여 진행한다. 나머지는 그대로 진행하면 된다.

## Install Steps
0. [kfctl 설치](https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/Kubeflow/README.md#step-0-kfctl-%EC%84%A4%EC%B9%98)
1. [설치 디렉토리 생성](https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/Kubeflow/README.md#step-1-%EC%84%A4%EC%B9%98-%EB%94%94%EB%A0%89%ED%86%A0%EB%A6%AC-%EC%83%9D%EC%84%B1)
2. [Kustomize 리소스 생성](https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/Kubeflow/README.md#step-2-kustomize-%EB%A6%AC%EC%86%8C%EC%8A%A4-%EC%83%9D%EC%84%B1)
3. [Kubeflow 배포](https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/Kubeflow/README.md#step-3-kubeflow-%EB%B0%B0%ED%8F%AC)
4. [배포 확인 및 기타 작업](https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/Kubeflow/README.md#step-4-%EB%B0%B0%ED%8F%AC-%ED%99%95%EC%9D%B8-%EB%B0%8F-%EA%B8%B0%ED%83%80-%EC%9E%91%EC%97%85)

## Step 0. kfctl 설치
* 목적 : `Kubeflow component를 배포 및 관리하기 위한 커맨드 라인툴인 kfctl을 설치한다.`
* 생성 순서 : 아래 명령어를 수행하여 kfctl을 설치한다. (Kubeflow v1.0.2 기준)
    ```bash
    $ wget https://github.com/kubeflow/kfctl/releases/download/v1.2.0/kfctl_v1.2.0-0-gbc038f9_linux.tar.gz
    $ tar xzvf kfctl_v1.2.0-0-gbc038f9_linux.tar.gz
    $ sudo mv kfctl /usr/bin
    ```
* 비고 : 
    * 폐쇄망 환경일 경우 kfctl_v1.0.2-0-ga476281_linux.tar.gz을 github에서 받는 것이 아니라 미리 다운로드 해둔 것을 사용하면 된다.

## Step 1. 설치 디렉토리 생성
* 목적 : `Kubeflow의 설치 yaml이 저장될 설치 디렉토리를 생성하고 해당 경로로 이동한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 설치 디렉토리를 생성하고 해당 경로로 이동한다.
        ```bash
        $ export KF_NAME=kubeflow
        $ export BASE_DIR=/home/${USER}
        $ export KF_DIR=${BASE_DIR}/${KF_NAME}
        $ mkdir -p ${KF_DIR}
        $ cd ${KF_DIR}
        ```
    * ${KF_DIR}이 설치 디렉토리이며 ${KF_NAME}, ${BASE_DIR}은 임의로 변경 가능하다.

## Step 2. Kustomize 리소스 생성
* 목적 : `Kubeflow는 Kubernetes 리소스 배포 툴인 Kustomize를 통해 설치된다. 이를 위해 Kubeflow를 설치하는 Kustomize 리소스를 생성한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 Kustomize 리소스를 생성한다.
        ```bash
        $ export CONFIG_URI="https://raw.githubusercontent.com/tmax-cloud/kubeflow-manifests/kubeflow-manifests-v1.0.2/kfctl_hypercloud_kubeflow.v1.0.2.yaml"
        $ kfctl build -V -f ${CONFIG_URI}
        ```
    * 정상적으로 완료되면 kustomize라는 디렉토리가 생성된다.
* 비고 : 
    * 폐쇄망 환경일 경우 설치 디렉토리 ${KF_DIR}에 미리 다운로드받은 sed.sh, kustomize_local.tar.gz 파일을 옮긴다.
    * 아래 명령어를 통해 Kustomize 리소스의 압축을 풀고 yaml 파일들에서 이미지들을 pull 받을 registry를 바꿔준다.
        ```bash
        $ tar xvfz kustomize_local.tar.gz
        $ chmod +x ./sed.sh
        $ ./sed.sh ${REGISTRY_ADDRESS} ${KF_DIR}/kustomize
        ```

## Step 3. Kubeflow 배포
* 목적 : `Kustomize 리소스를 apply하여 Kubeflow를 배포한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 Kubeflow를 배포한다.
        ```bash
        $ export CONFIG_FILE=${KF_DIR}/kfctl_hypercloud_kubeflow.v1.0.2.yaml
        $ kfctl apply -V -f ${CONFIG_FILE}
        ```
    * 아래와 같이, cert-manager 관련 오류가 계속 뜨는 현상이 있을 수 있는데, 이는 관련 컴포넌트들이 아직 로딩중이라 발생하는 것으로, 기다리자.
    
        ![pasted image 0](https://user-images.githubusercontent.com/63379907/90479302-6aedb380-e169-11ea-8c6c-9c1b4e15517a.png)
    * 설치에는 약 10분 정도가 소요된다.
* 비고 :
    * 폐쇄망 환경일 경우 설치 디렉토리 ${KF_DIR}에 미리 다운로드받은 kfctl_hypercloud_kubeflow.v1.0.2_local.yaml 파일을 옮긴다.
    * 아래 명령어를 수행하여 Kubeflow를 배포한다.
        ```bash
        $ export CONFIG_FILE=${KF_DIR}/kfctl_hypercloud_kubeflow.v1.0.2_local.yaml
        $ kfctl apply -V -f ${CONFIG_FILE}
        ```
    * 기존 Kubeflow에서 수정된 점
        * Istio 1.5.1 호환을 위해 KFServing의 controller 수정
        * Workflow template을 사용하기 위한 argo controller 버전 업
        * Notebook CRD, controller 변경

## Step 4. 배포 확인 및 기타 작업
* 목적 : `Kubeflow 배포를 확인하고 문제가 있을 경우 정상화한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 kubeflow namespace의 모든 pod가 정상적인지 확인한다.
        ```bash
        $ kubectl get pod -n kubeflow
        ```
    * 만약 아래 두 pod가 Running 상태가 아니라면 katib-mysql이라는 PVC의 mount에 문제가 있는 것이다.
        * katib-db-manager-...
        * katib-mysql-...
    * 아래 명령어 수행하여 PVC를 재생성한다.
        ```bash
        $ VOLUME_NAME=$(kubectl get pvc katib-mysql -n kubeflow -o yaml |grep volumeName |cut -c 15-)
        $ kubectl delete pvc katib-mysql -n kubeflow
        $ cat > katib-mysql.yaml <<EOF
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          labels:
            app.kubernetes.io/component: katib
            app.kubernetes.io/instance: katib-controller-0.8.0
            app.kubernetes.io/managed-by: kfctl
            app.kubernetes.io/name: katib-controller
            app.kubernetes.io/part-of: kubeflow
            app.kubernetes.io/version: 0.8.0
          name: katib-mysql
          namespace: kubeflow
        spec:
          accessModes:
          - ReadWriteOnce
          resources:
            requests:
              storage: 10Gi
          storageClassName: csi-cephfs-sc
          volumeMode: Filesystem
          volumeName: ${VOLUME_NAME}
        EOF
        $ kubectl apply -f katib-mysql.yaml
        ```
    * 모든 pod의 상태가 정상이라면 KFServing과 Istio 1.5.1과의 호환을 위해 아래 명령어를 수행하여 Istio의 mTLS 기능을 disable한다.
        ```bash
        $ echo '{"apiVersion":"security.istio.io/v1beta1","kind":"PeerAuthentication","metadata":{"annotations":{},"name":"default","namespace":"istio-system"},"spec":{"mtls":{"mode":"DISABLE"}}}' |cat > disable-mtls.json
        $ kubectl apply -f disable-mtls.json
        ```
## 기타 : kubeflow 삭제
* 목적 : `kubeflow 설치 시에 배포된 모든 리소스를 삭제 한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 kubeflow 모듈을 삭제한다.
        ```bash
        $ export CONFIG_URI="https://raw.githubusercontent.com/tmax-cloud/kubeflow-manifests/kubeflow-manifests-v1.0.2/kfctl_hypercloud_kubeflow.v1.0.2.yaml"
        $ kfctl delete -V -f ${CONFIG_URI}
        ```
* 비고 :
    * kfctl 1.1버전 이상부터 리소스의 삭제가 정상적으로 이루어진다. kfctl 버전은 다음명령어를 통해 확인할 수 있다.
        ```bash
        $ kfctl version
        ```