#!/usr/bin/env bash

kubectl create secret generic api-config -n taskapp --dry-run=client -o yaml \
  --from-file=api-config.yaml=../app/api-config.yaml | tee ./api-config-secret.yaml
