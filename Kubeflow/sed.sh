#!/bin/bash

registry=""
dir=""

if [ $# -eq 2 ];  then
	registry=$1
	dir=$2
else 
	echo "[$0] ERROR!! Invalid argument count"
	echo "[$0] [Usage] $0 192.168.6.110:5000 ${KF_DIR}/kustomize"
	exit 1
fi

echo "[$0] Modify images in Kustomize manifest files"

sed -i "s/newName: gcr.io\/ml-pipeline\/api-server/newName: ${registry}\/gcr.io\/ml-pipeline\/api-server/g" ${dir}/api-service/base/kustomization.yaml
sed -i "s/newName: gcr.io\/kubeflow-images-public\/kubernetes-sigs\/application/newName: ${registry}\/gcr.io\/kubeflow-images-public\/kubernetes-sigs\/application/g" ${dir}/application/base/kustomization.yaml
sed -i "s/image: argoproj\/argocli/image: ${registry}\/argoproj\/argocli/g" ${dir}/argo/base/deployment.yaml
sed -i "s/image: argoproj\/workflow-controller/image: ${registry}\/argoproj\/workflow-controller/g" ${dir}/argo/base/deployment.yaml
sed -i "s/image: gcr.io\/kubeflow-images-public\/ingress-setup/image: ${registry}\/gcr.io\/kubeflow-images-public\/ingress-setup/g" ${dir}/bootstrap/base/stateful-set.yaml
sed -i "s/newName: gcr.io\/kubeflow-images-public\/centraldashboard/newName: ${registry}\/gcr.io\/kubeflow-images-public\/centraldashboard/g" ${dir}/centraldashboard/base/kustomization.yaml
sed -i "s/image: \"quay.io\/jetstack\/cert-manager-cainjector/image: \"${registry}\/quay.io\/jetstack\/cert-manager-cainjector/g" ${dir}/cert-manager/base/deployment.yaml
sed -i "s/image: \"quay.io\/jetstack\/cert-manager-webhook/image: \"${registry}\/quay.io\/jetstack\/cert-manager-webhook/g" ${dir}/cert-manager/base/deployment.yaml
sed -i "s/image: \"quay.io\/jetstack\/cert-manager-controller/image: \"${registry}\/quay.io\/jetstack\/cert-manager-controller/g" ${dir}/cert-manager/base/deployment.yaml
sed -i "s/image: \"docker.io\/istio\/proxyv2/image: \"${registry}\/docker.io\/istio\/proxyv2/g" ${dir}/kfserving-gateway\/base\/deployment.yaml
sed -i "s/image: \"docker.io\/istio\/proxyv2/image: \"${registry}\/docker.io\/istio\/proxyv2/g" ${dir}/cluster-local-gateway\/base\/deployment.yaml
sed -i "s/newName: gcr.io\/kubeflow-images-public\/jupyter-web-app/newName: ${registry}\/gcr.io\/kubeflow-images-public\/jupyter-web-app/g" ${dir}/jupyter-web-app\/base\/kustomization.yaml
sed -i "s/gcr.io\/kubeflow-images-public\/tensorflow-1.14.0-notebook-cpu/${registry}\/gcr.io\/kubeflow-images-public\/tensorflow-1.14.0-notebook-cpu/g" ${dir}/jupyter-web-app/base/config-map.yaml
sed -i "s/gcr.io\/kubeflow-images-public\/tensorflow-1.15.2-notebook-cpu/${registry}\/gcr.io\/kubeflow-images-public\/tensorflow-1.15.2-notebook-cpu/g" ${dir}/jupyter-web-app/base/config-map.yaml
sed -i "s/gcr.io\/kubeflow-images-public\/tensorflow-1.15.2-notebook-gpu/${registry}\/gcr.io\/kubeflow-images-public\/tensorflow-1.15.2-notebook-gpu/g" ${dir}/jupyter-web-app/base/config-map.yaml
sed -i "s/gcr.io\/kubeflow-images-public\/tensorflow-2.1.0-notebook-cpu/${registry}\/gcr.io\/kubeflow-images-public\/tensorflow-2.1.0-notebook-cpu/g" ${dir}/jupyter-web-app/base/config-map.yaml
sed -i "s/gcr.io\/kubeflow-images-public\/tensorflow-2.1.0-notebook-gpu/${registry}\/gcr.io\/kubeflow-images-public\/tensorflow-2.1.0-notebook-gpu/g" ${dir}/jupyter-web-app/base/config-map.yaml
sed -i "s/\"image\": \"gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/file-metrics-collector/\"image\": \"${registry}\/gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/file-metrics-collector/g" ${dir}/katib-controller\/base\/katib-configmap.yaml
sed -i "s/\"image\": \"gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/file-metrics-collector/\"image\": \"${registry}\/gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/file-metrics-collector/g" ${dir}/katib-controller\/base\/katib-configmap.yaml
sed -i "s/\"image\": \"gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/tfevent-metrics-collector/\"image\": \"${registry}\/gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/tfevent-metrics-collector/g" ${dir}/katib-controller\/base\/katib-configmap.yaml
sed -i "s/\"image\": \"gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/suggestion-hyperopt/\"image\": \"${registry}\/gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/suggestion-hyperopt/g" ${dir}/katib-controller\/base\/katib-configmap.yaml
sed -i "s/\"image\": \"gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/suggestion-chocolate/\"image\": \"${registry}\/gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/suggestion-chocolate/g" ${dir}/katib-controller\/base\/katib-configmap.yaml
sed -i "s/\"image\": \"gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/suggestion-hyperband/\"image\": \"${registry}\/gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/suggestion-hyperband/g" ${dir}/katib-controller\/base\/katib-configmap.yaml
sed -i "s/\"image\": \"gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/suggestion-skopt/\"image\": \"${registry}\/gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/suggestion-skopt/g" ${dir}/katib-controller\/base\/katib-configmap.yaml
sed -i "s/\"image\": \"gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/suggestion-hyperopt/\"image\": \"${registry}\/gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/suggestion-hyperopt/g" ${dir}/katib-controller\/base\/katib-configmap.yaml
sed -i "s/\"image\": \"gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/suggestion-nasrl/\"image\": \"${registry}\/gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/suggestion-nasrl/g" ${dir}/katib-controller\/base\/katib-configmap.yaml
sed -i "s/image: docker.io\/kubeflowkatib\/mxnet-mnist/image: ${registry}\/docker.io\/kubeflowkatib\/mxnet-mnist/g" ${dir}/katib-controller\/base\/trial-template-configmap.yaml
sed -i "s/newName: gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/katib-controller/newName: ${registry}\/gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/katib-controller/g" ${dir}/katib-controller/base/kustomization.yaml
sed -i "s/newName: gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/katib-db-manager/newName: ${registry}\/gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/katib-db-manager/g" ${dir}/katib-controller/base/kustomization.yaml
sed -i "s/newName: gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/katib-ui/newName: ${registry}\/gcr.io\/kubeflow-images-public\/katib\/v1alpha3\/katib-ui/g" ${dir}/katib-controller/base/kustomization.yaml
sed -i "s/image: mysql/image: ${registry}\/mysql/g" ${dir}/katib-controller\/base\/katib-mysql-deployment.yaml
sed -i "s/image: mysql/image: ${registry}\/mysql/g" ${dir}/mysql\/base\/deployment.yaml
sed -i "s/image: mysql/image: ${registry}\/mysql/g" ${dir}/metadata\/overlays\/db\/metadata-db-deployment.yaml
sed -i "s/image: \"docker.io\/istio\/proxyv2/image: \"${registry}\/docker.io\/istio\/proxyv2/g" ${dir}/kfserving-gateway\/base\/deployment.yaml
sed -i "s/image: \"docker.io\/istio\/proxyv2/image: \"${registry}\/docker.io\/istio\/proxyv2/g" ${dir}/cluster-local-gateway\/base\/deployment.yaml
sed -i "s/\"image\" : \"gcr.io\/kfserving\/batcher/\"image\" : \"${registry}\/gcr.io\/kfserving\/batcher/g" ${dir}/kfserving-install\/base\/config-map.yaml
sed -i "s/\"image\" : \"gcr.io\/kfserving\/alibi-explainer/\"image\" : \"${registry}\/gcr.io\/kfserving\/alibi-explainer/g" ${dir}/kfserving-install\/base\/config-map.yaml
sed -i "s/\"image\" : \"gcr.io\/kfserving\/logger/\"image\" : \"${registry}\/gcr.io\/kfserving\/logger/g" ${dir}/kfserving-install\/base\/config-map.yaml
sed -i "s/\"image\": \"tensorflow\/serving/\"image\": \"${registry}\/tensorflow\/serving/g" ${dir}/kfserving-install\/base\/config-map.yaml
sed -i "s/\"image\": \"mcr.microsoft.com\/onnxruntime\/server/\"image\": \"${registry}\/mcr.microsoft.com\/onnxruntime\/server/g" ${dir}/kfserving-install\/base\/config-map.yaml
sed -i "s/\"image\": \"gcr.io\/kfserving\/sklearnserver/\"image\": \"${registry}\/gcr.io\/kfserving\/sklearnserver/g" ${dir}/kfserving-install\/base\/config-map.yaml
sed -i "s/\"image\": \"gcr.io\/kfserving\/xgbserver/\"image\": \"${registry}\/gcr.io\/kfserving\/xgbserver/g" ${dir}/kfserving-install\/base\/config-map.yaml
sed -i "s/\"image\": \"gcr.io\/kfserving\/pytorchserver/\"image\": \"${registry}\/gcr.io\/kfserving\/pytorchserver/g" ${dir}/kfserving-install\/base\/config-map.yaml
sed -i "s/\"image\": \"nvcr.io\/nvidia\/tritonserver/\"image\": \"${registry}\/nvcr.io\/nvidia\/tritonserver/g" ${dir}/kfserving-install\/base\/config-map.yaml
sed -i "s/\"image\" : \"gcr.io\/kfserving\/storage-initializer/\"image\" : \"${registry}\/gcr.io\/kfserving\/storage-initializer/g" ${dir}/kfserving-install\/base\/config-map.yaml
sed -i "s/image: gcr.io\/kfserving\/kfserving-controller/image: ${registry}\/gcr.io\/kfserving\/kfserving-controller/g" ${dir}/kfserving-install\/base\/statefulset.yaml
sed -i "s/image: gcr.io\/kubebuilder\/kube-rbac-proxy/image: ${registry}\/gcr.io\/kubebuilder\/kube-rbac-proxy/g" ${dir}/kfserving-install\/base\/statefulset.yaml
sed -i "s/image: tmaxcloudck\/hypercloud-kfserving/image: ${registry}\/tmaxcloudck\/hypercloud-kfserving/g" ${dir}/kfserving-install\/base\/statefulset.yaml
sed -i "s/newName: gcr.io\/knative-releases\/knative.dev\/serving\/cmd/newName: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd/g" ${dir}/knative-install/base/kustomization.yaml
sed -i "s/image: gcr.io\/knative-releases\/knative.dev\/serving\/cmd/image: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd/g" ${dir}/knative-install/base/image.yaml
sed -i "s/image: metacontroller\/metacontroller/image: ${registry}\/metacontroller\/metacontroller/g" ${dir}/metacontroller\/base\/stateful-set.yaml
sed -i "s/image: gcr.io\/kubeflow-images-public\/metadata-frontend/image: ${registry}\/gcr.io\/kubeflow-images-public\/metadata-frontend/g" ${dir}/metadata\/base\/metadata-ui-deployment.yaml
sed -i "s/image: gcr.io\/kubeflow-images-public\/metadata/image: ${registry}\/gcr.io\/kubeflow-images-public\/metadata/g" ${dir}/metadata\/base\/metadata-deployment.yaml
sed -i "s/image: gcr.io\/ml-pipeline\/envoy:metadata-grpc/image: ${registry}\/gcr.io\/ml-pipeline\/envoy:metadata-grpc/g" ${dir}/metadata\/base\/metadata-envoy-deployment.yaml
sed -i "s/image: gcr.io\/tfx-oss-public\/ml_metadata_store_server/image: ${registry}\/gcr.io\/tfx-oss-public\/ml_metadata_store_server/g" ${dir}/metadata\/base\/metadata-deployment.yaml
sed -i "s/image: gcr.io\/kubeflow-images-public\/metadata-frontend/image: ${registry}\/gcr.io\/kubeflow-images-public\/metadata-frontend/g" ${dir}/metadata\/base\/metadata-ui-deployment.yaml
sed -i "s/image: minio\/minio/image: ${registry}\/minio\/minio/g" ${dir}/minio\/base\/deployment.yaml
sed -i "s/image: tmaxcloudck\/notebook-controller-go:b0.0.2/image: ${registry}\/tmaxcloudck\/notebook-controller-go:b0.0.2/g" ${dir}/notebook-controller\/base\/deployment.yaml
sed -i "s/newName: gcr.io\/ml-pipeline\/persistenceagent/newName: ${registry}\/gcr.io\/ml-pipeline\/persistenceagent/g" ${dir}/persistent-agent/base/kustomization.yaml
sed -i "s/newName: gcr.io\/ml-pipeline\/frontend/newName: ${registry}\/gcr.io\/ml-pipeline\/frontend/g" ${dir}/pipelines-ui/base/kustomization.yaml
sed -i "s/newName: gcr.io\/ml-pipeline\/viewer-crd-controller/newName: ${registry}\/gcr.io\/ml-pipeline\/viewer-crd-controller/g" ${dir}/pipelines-viewer/base/kustomization.yaml
sed -i "s/newName: gcr.io\/ml-pipeline\/visualization-server/newName: ${registry}\/gcr.io\/ml-pipeline\/visualization-server/g" ${dir}/pipeline-visualization-service/base/kustomization.yaml
sed -i "s/newName: gcr.io\/kubeflow-images-public/newName: ${registry}\/gcr.io\/kubeflow-images-public/g" ${dir}/profiles/base/kustomization.yaml
sed -i "s/newName: gcr.io\/kubeflow-images-public\/pytorch-operator/newName: ${registry}\/gcr.io\/kubeflow-images-public\/pytorch-operator/g" ${dir}/pytorch-operator/base/kustomization.yaml
sed -i "s/newName: gcr.io\/ml-pipeline\/scheduledworkflow/newName: ${registry}\/gcr.io\/ml-pipeline\/scheduledworkflow/g" ${dir}/scheduledworkflow/base/kustomization.yaml
sed -i "s/image: 'docker.io\/seldonio\/seldon-core-operator/image: '${registry}\/docker.io\/seldonio\/seldon-core-operator/g" ${dir}/seldon-core-operator\/base\/resources.yaml
sed -i "s/image: gcr.io\/spark-operator\/spark-operator/image: ${registry}\/gcr.io\/spark-operator\/spark-operator/g" ${dir}/spark-operator\/base\/deploy.yaml
sed -i "s/image: gcr.io\/spark-operator\/spark-operator/image: ${registry}\/gcr.io\/spark-operator\/spark-operator/g" ${dir}/spark-operator\/base\/crd-cleanup-job.yaml
sed -i "s/image: gcr.io\/google_containers\/spartakus-amd64/image: ${registry}\/gcr.io\/google_containers\/spartakus-amd64/g" ${dir}/spartakus\/base\/deployment.yaml
sed -i "s/image: tensorflow\/tensorflow/image: ${registry}\/tensorflow\/tensorflow/g" ${dir}/tensorboard\/base\/deployment.yaml
sed -i "s/newName: gcr.io\/kubeflow-images-public\/tf_operator/newName: ${registry}\/gcr.io\/kubeflow-images-public\/tf_operator/g" ${dir}/tf-job-operator/base/kustomization.yaml
sed -i "s/newName: gcr.io\/kubeflow-images-public\/admission-webhook/newName: ${registry}\/gcr.io\/kubeflow-images-public\/admission-webhook/g" ${dir}/webhook/base/kustomization.yaml

echo "[$0] Done"
