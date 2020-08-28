시나리오 전제: HyperCloud 4 UI만 가지고 아래 시나리오 수행
	- AI Ops의 각 메뉴를 최대한 활용
	- https://192.168.8.21:9000/

1. 노트북 생성 
	1) notebook yaml 작성
		- 승진연구원님 만드신 컨트롤러 사용하기러함
		- 생성된 pod에 docker login인 작업이 필요한데 이 작업이 번거로우니 미리 생성된 노트북을 사용
	2) 접속

2. 띄운 노트북으로 코딩
	1) fasion mnist 작성 (fairing을 통해 이미지 만드는 것까지)
	2) docker hub에서 배포된 이미지 확인

3. katib 튜닝
	1) 앞서만든 이미지를 통해 expertiment yaml 작성
		- experiment create 버튼 누른 후, UI 에러나는 현상이 있음
		- mayBe resourceVersion up이 되어 데이터가 새로 들어올때 화면을 새로 그리지 못하는 것으로 보임
	
	2) 모델 튜닝 결과 리뷰
		- experiment 최적 파라미터값이 overview화면에 안나오는건 아쉽
		- yaml로 접근해서 보자


4. TF job으로 분산트레이닝 !!
	1) 앞서만든 이미지와 튜닝값을 통해 TFJob yaml 작성
		- 결과값(saved_model)을 보여줄수 있기가 제한적임... pvc를 직접 봐야하니...
		- notebook에서 사용중인 pvc에 저장하고 보여준다!

5. kfserving으로 서빙 (까나리 잇으면 좋음)
	1) 앞서 만든 모델을 통해 inferenceservice yaml 작성
		- 까나리 모델은 미리 만들어 놓자 (ex. saved_model2)
	2 서비스를 활용한 간단한 웹어플리케이션 예시
	http://172.22.1.2:19000/?model=demo-inferenceservice&name=demo-inferenceservice.demo.example.com&addr=172.22.1.11


6. workflow
	0) 시작전 이전 만들었던 리소스 삭제 - inferenceservice, model
	1) 트레이닝 -> 서빙 과정 자동화를 위한 workflow 작성