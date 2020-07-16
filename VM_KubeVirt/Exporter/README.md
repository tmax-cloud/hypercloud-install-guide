# VM Exporter 설치 가이드

## 구성 요소 및 버전
* VM Exporter (vm-exporter:v2.0.0-3)

## Prerequisites
Kubernetes, KubeVirt, Prometheus가 설치되어 있어야 합니다.

## 폐쇄망 설치 가이드
폐쇄망에서 설치를 진행해야 하는 경우에도 추가 작업은 필요하지 않습니다.

## Install Steps
1. [Linux VM 내 Exporter 설치](#step-1-linux-vm-내-exporter-설치)
2. [Windows VM 내 Exporter 설치](#step-2-windows-vm-내-exporter-설치)
3. [Kubernetes 설정](#step-3-kubernetes-설정)

## Step 1. Linux VM 내 Exporter 설치
* 목적 : `Linux VM의 모니터링을 위한 VM Exporter 설치 및 설정`
* 생성 순서 :
  * "vm_exporter" (binary executable) 파일 실행
    * Process로서 실행해야 함
    * Service 등을 통해 background process 형태로 설치하는 것을 권장
  * Open port 9226 (TCP inbound)
  * Memory Limit 설정 (Optional)
    * Cgroups를 통해 Memory Limit을 25MB로 설정
    * Example (run commands as <b>root</b>):
    ```bash
    mkdir /dev/cgroups
    mount -t cgroup -omemory memory /dev/cgroups
    mkdir /dev/cgroups/vm-exporter
    echo 25000000 > /dev/cgroups/vm-exporter/memory.limit_in_bytes
    pidof vm_exporter > /dev/cgroups/vm-exporter/tasks
    ```
* 비고 : 
  * 모니터링 하고자 하는 모든 Linux VM 내에서 실행

## Step 2. Windows VM 내 Exporter 설치
* 목적 : `Windows VM의 모니터링을 위한 VM Exporter 설치 및 설정`
* 생성 순서 : 
  * "vm_exporter.exe" (binary executable) 파일 실행
    * Process로서 실행해야 함
    * 작업 스케줄러(Windows Task Scheduler) 등을 통해 background process 형태로 설치하는 것을 권장
  * Open port 9226 (TCP inbound)
* 비고 : 
  * 모니터링 하고자 하는 모든 Windows VM 내에서 실행

## Step 3. Kubernetes 설정
* 목적 : `Prometheus - VM Exporter 연동`
* 생성 순서 : 
  * 다음 명령어를 실행하여 Service와 ServiceMonitor 생성
  ```bash
  kubectl create -f vm-exporter.yaml
  ```
    * VM이 default namespace가 아닌 다른 namespace에 존재하는 경우, VM이 있는 모든 namespace에 대해 아래 명령어 실행
    ```bash
    cat vm-exporter.yaml | sed "s/default/[name of namespace]/g" | kubectl create -f -
    ```
* 비고 : 
  * 모든 명령어는 Kubernetes Master Node에서 관련 permission이 있는 계정으로 실행
