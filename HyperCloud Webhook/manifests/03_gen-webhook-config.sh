#!/bin/bash
export HYPERCLOUD4_CA_CERT=$(openssl base64 -A <"./pki/ca.crt")

WEBHOOK_CONFIG_FILE=04_webhook-configuration.yaml
if [ -f "$WEBHOOK_CONFIG_FILE" ]; then
   echo "Remove existed webhook config file."
   rm $WEBHOOK_CONFIG_FILE
fi

echo "Generate webhook config file."
envsubst < ./"$WEBHOOK_CONFIG_FILE".template  > "$WEBHOOK_CONFIG_FILE"
