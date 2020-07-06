
# Kubeflow 설치 가이드

## 구성 요소 및 버전
* Kubeflow v1.0.2 (https://github.com/kubeflow/kubeflow)
* Argo v2.8 (https://github.com/argoproj/argo)
* Jupyter (https://github.com/jupyter/notebook)
* Katib v0.8.0 (https://github.com/kubeflow/katib)
* KFServing v0.2.2 (https://github.com/kubeflow/kfserving)
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
        * https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Rook%20Ceph/README.md
    * Storage class는 있지만 default로 설정된 것이 없다면 아래 명령어를 실행한다.
    ```bash
    $ kubectl patch storageclass <<STORAGE_CLASS_NAME>> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    ```
2. Istio
    * v1.5.1
        * https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Istio
3. GPU plug-in (Optional)
    * Kubernetes cluster 내 node에 GPU가 탑재되어 있으며 AI DevOps 기능을 사용할 때 GPU가 요구될 경우에 필요하다.
        * https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Pod_GPU%20plugin

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. 이미지 준비
    * 아래 링크를 참고하여 폐쇄망에서 사용할 registry를 구축한다.
        * 폐쇄망 registry 구축 링크
    * 아래 명령어를 수행하여 Kubeflow 설치 시 필요한 이미지들을 위에서 구축한 registry에 push한다.
    ```bash
    $ wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/master/Kubeflow/image-push.sh
    $ wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/master/Kubeflow/imagelist
    $ chmod +x ./image-push.sh
    $ ./image-push.sh <<REGISTRY_ADDRESS>>
    ```
2. Yaml 파일 및 script 파일 준비
    * 아래 명령어를 수행하여 Kubeflow 설치에 필요한 yaml 파일들과 script 파일들을 다운로드 받는다. 
    ```bash
    $ wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/master/Kubeflow/sed.sh
    $ wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/master/Kubeflow/kustomize-apply.sh
    $ wget https://raw.githubusercontent.com/tmax-cloud/hypercloud-install-guide/master/Kubeflow/kustomize.tar.gz
    ```
3. 앞으로의 진행
    * Step 0 ~ 4 중 Step 0은 진행할 필요없고 2, 3은 비고를 참고하여 진행한다. 나머지는 그대로 진행하면 된다.

## Install Steps
0. [kfctl 설치](https://스텝_0로_바로_가기_위한_링크)
1. [설치 디렉토리 생성](https://스텝_1로_바로_가기_위한_링크)
2. [Kustomize 리소스 생성](https://스텝_2로_바로_가기_위한_링크)
3. [Kubeflow 배포]()
4. [배포 확인 및 기타 작업]()

## Step 0. kfctl 설치
* 목적 : `Kubeflow component를 배포 및 관리하기 위한 커맨드 라인툴인 kfctl을 설치한다.`
* 생성 순서 : 아래 명령어를 수행하여 kfctl을 설치한다. (Kubeflow v1.0.2 기준)
    ```bash
    $ wget https://github.com/kubeflow/kfctl/releases/download/v1.0.2/kfctl_v1.0.2-0-ga476281_linux.tar.gz
    $ tar xzvf kfctl_v1.0.2-0-ga476281_linux.tar.gz
    $ sudo mv kfctl /usr/bin
    ```

## Step 1. 설치 디렉토리 생성
* 목적 : `Kubeflow의 설치 yaml이 저장될 설치 디렉토리를 생성하고 해당 경로로 이동한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 설치 디렉토리를 생성하고 해당 경로로 이동한다.
    * ${KF_DIR}이 설치 디렉토리이며 ${KF_NAME}, ${BASE_DIR}은 임의로 변경 가능하다.
    ```bash
    $ export KF_NAME=kubeflow
    $ export BASE_DIR=/home/${USER}
    $ export KF_DIR=${BASE_DIR}/${KF_NAME}
    $ mkdir -p ${KF_DIR}
    $ cd ${KF_DIR}
    ```

## Step 2. Kustomize 리소스 생성
* 목적 : `Kubeflow는 Kubernetes 리소스 배포 툴인 Kustomize를 통해 설치된다. 이를 위해 Kubeflow를 설치하는 Kustomize 리소스를 생성한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 Kustomize 리소스를 생성한다.
    * 정상적으로 완료되면 kustomize라는 디렉토리가 생성된다.
    ```bash
    $ export CONFIG_URI="https://raw.githubusercontent.com/tmax-cloud/kubeflow-manifests/kubeflow-manifests-v1.0.2/kfctl_hypercloud_kubeflow.v1.0.2.yaml"
    $ kfctl build -V -f ${CONFIG_URI}
    ```
* 비고 : 
    * 폐쇄망 환경일 경우 설치 디렉토리에 미리 다운로드받은 sed.sh, kustomize-apply.sh, kustomize.tar.gz 파일을 옮긴다.
    * 아래 명령어를 통해 Kustomize 리소스의 압축을 풀고 yaml 파일들에서 이미지들을 pull 받을 registry를 바꿔준다.
    ```bash
    $ tar xvfz kustomize.tar.gz
    $ chmod +x ./sed.sh
    $ ./sed.sh <<REGISTRY_ADDRESS>> ${KF_DIR}/kustomize
    ```

## Step 3. Kubeflow 배포
* 목적 : `Kustomize 리소스를 apply하여 Kubeflow를 배포한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 Kubeflow를 배포한다.
    * 설치에는 약 10분 정도가 소요된다.
    ```bash
    $ export CONFIG_FILE=${KF_DIR}/kfctl_hypercloud_kubeflow.v1.0.2.yaml
    $ kfctl apply -V -f ${CONFIG_FILE}
    ```
* 비고 :
    * 기존 Kubeflow에서 수정된 점
        * Istio 1.5.1 호환을 위해 KFServing의 controller 수정
        * Workflow template을 사용하기 위한 argo controller 버전 업
    * 폐쇄망 환경일 경우 kfctl 대신 아래 명령어를 통해 Kubeflow를 배포한다.
    ```bash
    $ chmod +x ./kustomize-apply.sh
    $ ./kustomize-apply.sh ${KF_DIR}/kustomize
    ```

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
