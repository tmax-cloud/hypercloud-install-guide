# Hyperflow를 사용한 AI 개발 시나리오 가이드
가이드 문의 CK2-4팀

주의 사항 : 
 - notebook-controller-go image b0.0.2 이상 버전, hypercloud-console image 4.1.2.3.0 이상 버전에서 notebook이 UI에 정상 표기
 - image 버전 확인 방법 : HyperCloud 마스터 노드에서 다음의 커맨드를 입력하여 나오는 image 정보 확인
```
kubectl get deploy -n kubeflow notebook-controller-deployment -o wide
kubectl get deploy -n console-system console -o wide
```
## 간단한 AI 개발과정 소개
![ai-process.PNG](./img/ai-process.PNG)
AI 개발과정에는 Experimental 단계와 Production 단계로 나눠 생각해볼 수 있다.

Experimental 단계는 모델 개발 과정으로써 완성도가 높은 ML 모델을 찾는 것이 목적이며,
데이터 수집하기, 모델 코딩하기, 모델 트레이닝 및 테스트, 모델 튜닝하기 과정이 포함된다. *본 시나리오 Step 2,3 과정

Production 단계는 실제 운영 과정으로써 ML모델을 서비스하는 것이 목적이다. 
experimental 단계에서 나온 모델을 토대로 더 큰 스케일에서 모델 트레이닝하기, 모델 서빙하기, 모니터링 과정이 포함된다. *본 시나리오 Step 4,5 과정

## 시나리오 요약
Fashion-MNIST 데이터를 활용하여 Image가 어떤 Fashion Item인지 추론하는 ML service를 만든다.

### 구체적인 순서
  0. 작업을 위한 namespace, pvc 만들기
  1. ML 코드 작성을 위한 notebook 만들기
  2. ML model을 코딩하고, 클라우드 작업을 위한 image 생성하기
  3. hyper-parameter tuning을 위한 katib 사용하기
  4. Model 학습을 위한 tfjob 생성하기
  5. Model 서빙을 위한 kfserving 사용하기
  6. process 자동화를 위한 workflow 생성하기


---

## Step 0. 작업을 위한 namespace, pvc 만들기
  - hyperflow에서는 작업하려는 namespace를 profile이라는 crd를 통해 관리한다.
  - hyperflow 기능을 사용하기 위한 role, rolebinding등의 k8s리소스 배포 뿐만아니라 istio-injection 활성화와 같은 작업을 자동으로 진행한다.
  - master node에서 kubectl create 커맨드를 활용하여 demo profile을 생성한다. 
  ```
  $ kubectl apply -f 0.profile.yaml
  ```
  - 참고 : [0.profile.yaml](./0.profile.yaml)

*현재, hyperCloud Console상에는 해당 리소스를 배포할 수 있는 UI가 없다. 추 후, 유저 권한관리와 엮어 기능 업데이트 예정이다.

  - 본 시나리오의 작업을 위해 demo-pvc(readWriteMany)를 생성한다.

![0.pvc.PNG](./img/0.pvc.PNG)  
  - 참고 : [0.pvc.yaml](./0.pvc.yaml)

## Step 1. python 코드 작성을 위한 notebook 만들기 (Notebook Server 메뉴)
  - hyperflow에서는 ML Model 코딩을 위한 web 기반의 python IDE인 JupyterNotebook을 사용할 수 있다.
  - 위에서 생성한 demo-pvc를 마운트하는 demo-notebook을 생성한다. 

![1.notebook.PNG](./img/1.notebook.PNG)
  - 참고 : [1.notebook.yaml](./1.notebook.yaml)

*시나리오에서는 여러 커스텀 패키지가 포함된 custom jupyterNotebook image를 사용하였다. (brightfly/kubeflow-jupyter-lab:tf2.0-gpu)

  - 정상적인 배포를 확인하기 위해, action->connect 버튼을 눌러 jupyter진입을 확인하자.

![1.notebook-connect.PNG](./img/1.notebook-connect.PNG)


## Step 2. ML model을 코딩하고, 클라우드 작업을 위한 image 생성하기
  - tensorflow 모듈을 활용하여 ML 코드를 작성하고, kubeflow 모듈을 활용하여 ML image를 배포한다.
  - 정상적으로 image를 배포하기 위해, jupyterNotebook container에 docker registry 인증정보를 넣어야한다.
  - 시나리오에서는 public registry인 docker hub를 활용하였고, 인증이 적용된 private registry 또한 사용 가능하다.  

### 인증 방법 1) 로컬 개발 환경의 docker registry 인증정보 사용
 - docker에 로그인 되어있는 로컬 개발환경에서 config.json을 복사하여, jupyterNotebook container에 붙여넣는다.
 - 보통 docker registry 인증정보는 로컬개발환경 /root/.docker/config.json 파일을 찾을 수 있다. ( 안나온다면 다음의 위치를 본다. ${HOME}/.docker/config.json )
 - jupyterNotebook에서 터미널을 열어 /home/jovyan/.docker/config.json으로 복사하자

![2.notebook-docker-auth.PNG](./img/2.notebook-docker-auth.PNG)

### 인증 방법 2) docker client활용
  - docker hub와 통신하기 위해, jupyterNotebook에서 Terminal을 열어 다음 커맨드를 입력한다.
```
sudo apt update &&
sudo apt-get install software-properties-common -y && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo apt-key add - && \
sudo add-apt-repository \
"deb [arch=amd64]
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
sudo apt-get update && \
apt-cache policy docker-ce && \
sudo apt-get install -y docker-ce 
```
  - 이후, 다음 커맨드를 입력하여 docker hub login을 진행하자.
```
docker login
```
  - 로그인 후에 config.json이 /home/jovyan/.docker/config.json에 위치하는지 확인하고, 없다면 cp 커맨드를 통해 옮기자.
```
ls home/jovyan/.docker/
cp $HOME/.docker/config.json /home/jovyan/.docker/config.json
```

  - 위의 작업이 끝났다면, code run을 하여 이미지를 배포하자. (UI는 jupyter 버전에 따라 다를 수 있음)
  
![2.fmnist-save-model-renew.PNG](./img/2.fmnist-save-model-renew.PNG)
  - 참고 : [fmnist-save-model-renew.ipynb](./fmnist-save-model-renew.ipynb)
  
*kubeflow.fairing.builders.cluster.minio_context가 없다는 에러가 뜬다면, 다음 커맨드를 입력하여 kubeflow-fairing module을 업데이트하자
```
pip install kubeflow-fairing --upgrade
```

*실행이 잘 되지 않는다면, pythonNotebook의 kerner을 리셋 후 다시 code run을 진행하자. (code run 옆에 커널새로고침 버튼 클릭)

  - 아래와 같이 docker hub에 rhojw/sample-job:3C8CE2EE 의 image가 배포된 것을 확인할 수 있다. 이후 Step에 사용할 image이다. 

![2.docker-image.PNG](./img/2.docker-image.PNG)


## Step 3. hyper-parameter tuning을 위한 katib 사용하기 (Katib 메뉴)
  - hyper-parameter란 ML 모델 학습에 필요한 컨트롤 변수로, learningRate, dropoutRate, optimizer, neuralNetworkLayerNumber 등이 있다.
  - Katib를 통해 hyper-parameter 값들에 따른 모델 학습의 정확도(Accuracy)를 알 수 있으며, 본격적인 모델 학습에 이 값들이 사용된다.
  - 예시에는 살펴볼 hyper-parameter로 learningRate, dropoutRate를 설정하였다.

![3.katib-experiment.PNG](./img/3.katib-experiment.PNG)
  - 참고 : [3.katib-experiment.yaml](3.katib-experiment.yaml)
  - 모든 작업이 완료된다면, status 항목에서 ML 모델의 정확도가 가장 높은 hyper-parameter를 알려준다.
  - 아래 결과를 해석하자면 validation-accuracy가 최대로 나온 수치는 0.8392이고, 이때의 learningRate는 0.01393... dropoutRate는 0.84807...를 의미한다.

![3.katib-result.PNG](./img/3.katib-result.PNG)

## Step 4. Model 학습을 위한 tfjob 생성하기 (Training Jobs 메뉴)
  - hyper-parameter 탐색까지 끝났다면, 본격적인 Model 학습을 위해 tfJob을 생성한다.
  - Step 3에서 도출된 learningRate와 dropoutRate를 사용하여 모델을 학습한다. (learningRate 0.01393, dropoutRate 0.84807)
  - 시나리오에서는, 모델이 저장될 pvc를 notebook이 사용하는 pvc와 동일한 demo-pvc로 지정하였다.

![4.tfjob.PNG](./img/4.tfjob.PNG)
  - 참고 : [4.tfjob.yaml](4.tfjob.yaml)
  - 학습이 종료되면, pvc에 모델이 저장된다. 시나리오에서는 notebook UI를 통해 생성된 모델을 확인 가능하다.

![4.saved-model.PNG](./img/4.saved-model.PNG)

## Step 5. Model 서빙을 위한 kfserving 사용하기 (KFServing 메뉴)
  - 실제 운영에 쓰일 model을 기반으로 server를 만들고, inference service를 제공한다.

![5.kfserving-inferenceservice.PNG](./img/5.kfserving-inferenceservice.PNG)
  - 참고 : [5.kfserving-inferenceservice.yaml](5.kfserving-inferenceservice.yaml)
  - demo-inferenceservice가 성공적으로 생성되었다면, curl 을 이용하여 inference 응답이 오는지 확인하자. (마스터 노드에서 테스트 진행)
  ```
  MODEL_NAME=demo-inferenceservice
  CLUSTER_IP=$(kubectl -n istio-system get service kfserving-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  SERVICE_HOSTNAME=$(kubectl get inferenceservice ${MODEL_NAME} -n demo -o jsonpath='{.status.url}' | cut -d "/" -f 3)
  curl -v -H "Host: ${SERVICE_HOSTNAME}" http://$CLUSTER_IP/v1/models/$MODEL_NAME:predict -d '{
    "instances":[
      {
        "flatten_input":[
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        ]
      }
    ]
  }'
  ```

  - 참고 : [5.demo.sh](5.demo.sh)
  - 아래와 같은 응답이 오게 되는데, 간단하게 해석하자면 inference를 요청한 데이터는 class5(Sandal)일 확률이 0.988이라는 응답이다.

![5.curl.PNG](./img/5.curl.PNG)


### 간단한 웹앱을 통한 inference service 확인
  - 위의 inference service가 실제 어플리케이션에서 어떻게 활용되는지 확인할 수 있다.
  - Docker가 설치된 HyperCloud node에서 다음과 같이 입력한다.
  ```
  sudo docker run -p19000:5000 brightfly/fminst-webui:latest 
  ```
  - 웹브라우저 주소창에 http://{node IP}:19000/?model=demo-inferenceservice&name=demo-inferenceservice.demo.example.com&addr={istio-system nameSpace의 kfserving-ingressgateway ExternalIP}를 입력하여 접속

*kfserving-ingressgateway의 ExternalIP는 HyperCloud UI Network-service 메뉴에서 확인하거나 마스터 노드에서 다음 커맨드를 입력하여 확인한다.

```
kubectl get service -n istio-system kfserving-ingressgateway
```
  - 아래와 같이, 그림이 어떤 Fashion Item인지 유추해주는 간단한 webApp이다.

![5.web.PNG](./img/5.web.PNG)

## Step 6. process 자동화를 위한 workflow 생성하기 (Workflow 메뉴)
  - 실제 운영과정에서는 새로운 데이터를 통해 모델을 다시 학습하고 배포하는 일련의 작업들을 해야할 경우가 생기는데, 이를 자동화 해주는 메뉴이다.
  - 시나리오에서는 Step4와 Step5를 자동화 해주는 demo-workflow를 생성하였다.

*시나리오의 yaml을 배포하기 전에 이전에 만들어 두었던 trainingJob과 KFServing을 삭제하자

![5.workflow.PNG](./img/5.workflow.PNG)

  - 참고 : [6.workflow.yaml](6.workflow.yaml)

*serving 같은 경우 kfp python module을 사용하여 image로 만들고, 이를 workflow task로 등록하여 생성하였다. 참고 : [KFServing-fairing.ipynb](KFServing-fairing.ipynb)
