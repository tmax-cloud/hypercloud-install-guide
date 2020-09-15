#!/bin/bash
CURRENT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
export HYPERCLOUD4_CA_CERT=$(openssl base64 -A <"$CURRENT_PATH/../pki/ca.crt")

AUDIT_CONFIG_FILE=06_audit-webhook-config
if [ -f "$AUDIT_CONFIG_FILE" ]; then
   echo "Remove existed audit config file."
   rm $AUDIT_CONFIG_FILE
fi

echo "Generate audit config file."
envsubst < ./"$AUDIT_CONFIG_FILE".template  > "$AUDIT_CONFIG_FILE"
