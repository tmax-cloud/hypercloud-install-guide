#!/bin/bash
openssl req -nodes -new -x509 -keyout ./pki/ca.key -out ./pki/ca.crt -subj "/CN=Hypercloud4 Admission Controller Webhook CA" -days 365 && \
openssl genrsa -out ./pki/hypercloud4-webhook.key 2048 && \
openssl req -new -key ./pki/hypercloud4-webhook.key -subj "/CN=hypercloud4-webhook-svc.hypercloud4-system.svc" \
    | openssl x509 -req -CA ./pki/ca.crt -CAkey ./pki/ca.key -CAcreateserial -out ./pki/hypercloud4-webhook.crt -days 365
