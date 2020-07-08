
# Grafana 설정 가이드

## Install Steps
1. [ConfigMap에 Grafana config 생성](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Grafana/README.md#step-1-configmap%EC%97%90-grafana-config-%EC%83%9D%EC%84%B1)
2. [Deployment에 Grafana config 적용](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Grafana/README.md#step-2-deployment%EC%97%90-grafana-config-%EC%A0%81%EC%9A%A9)
3. [시연 대시보드 UID 및 설정 변경](https://github.com/tmax-cloud/hypercloud-install-guide/blob/master/Grafana/README.md#step-3-%EC%8B%9C%EC%97%B0-%EB%8C%80%EC%8B%9C%EB%B3%B4%EB%93%9C-uid-%EB%B0%8F-%EC%84%A4%EC%A0%95-%EB%B3%80%EA%B2%BD)
	


***

## Step 1. ConfigMap에 Grafana config 생성
* 목적 : Default 그라파나 컨테이너에서 하이퍼클라우드 서비스를 위해 일부 설정값을 변경함
* monitoring 네임스페이스에 다음 내용의 ConfigMaps를 추가한다([grafana-config](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Grafana/yaml/grafana-config.yaml))

***

## Step 2. Deployment에 Grafana config 적용
* 목적 : 변경한 설정값을 그라파나 Deployment에 적용함
* monitoring 네임스페이스의 grafana Deployment를 다음 yaml로 변경한다([deployment](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Grafana/yaml/grafana.yaml))
* 비고
	* 기존 Deployment의 내용에서 volumes와 volumeMounts에 grafana-config를 추가한 것이다

***

## Step 3. 시연 대시보드 UID 및 설정 변경
* 목적 : 대시보드 설정 변경
* monitoring 네임스페이스의 grafana-dashboard-k8s-resources-namespace ConfigMaps를 다음 yaml로 변경한다([dashboard](https://github.com/tmax-cloud/hypercloud-install-guide/tree/master/Grafana/yaml/grafana-dashboard-k8s-resources-namespace.yaml))
* 비고
	* 기존 ConfigMaps의 내용에서 uid와 변수의 hide값을 변경한 것이다


***

## Step 4. 확인
* 목적: HyperCloud에서 Grafana의 정상 동작을 확인함
* HyperCloud UI에서 현재 pod가 존재하는 네임스페이스를 지정한다.
* 메뉴에서 그라파나를 선택한 뒤 대시보드가 출력되면 성공.