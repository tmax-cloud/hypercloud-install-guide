#!/bin/bash
export HYPERCLOUD4_CA_CERT=$(openssl base64 -A <"./pki/ca.crt")

WEBHOOK_CONFIG_FILE=05_webhook-configuration.yaml
if [ -f "$WEBHOOK_CONFIG_FILE" ]; then
   echo "Remove existed webhook config file."
   rm $WEBHOOK_CONFIG_FILE
fi
if [ $ADM_VERSION = "v1" ];then
   export ADM_VERSION2="[\"v1\", \"v1beta1\"]"
elif [ $ADM_VERSION = "v1beta1" ];then
   export ADM_VERSION2="[\"v1beta1\"]"
else
   echo "ADM_VERSION is not defined!! Default Version is v1"
   export ADM_VERSION="v1"
   export ADM_VERSION2="[\"v1\", \"v1beta1\"]"
fi

echo "Generate webhook config file."
envsubst < ./"$WEBHOOK_CONFIG_FILE".template  > "$WEBHOOK_CONFIG_FILE"
