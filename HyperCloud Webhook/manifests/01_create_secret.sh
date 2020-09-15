#!/bin/bash
CURRENT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
kubectl -n hypercloud4-system delete secret hypercloud4-webhook-certs
kubectl -n hypercloud4-system create secret generic hypercloud4-webhook-certs \
    --from-file="$CURRENT_PATH"/../pki/hypercloud4-webhook.jks
