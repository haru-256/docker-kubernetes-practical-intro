#!/usr/bin/env bash

MYSQL_ROOT_PASSWORD=$(cat ../app/secrets/mysql_root_password)
MYSQL_USER_PASSWORD=$(cat ../app/secrets/mysql_user_password)

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  echo "MYSQL_ROOT_PASSWORD is not set"
  exit 1
fi
if [ -z "$MYSQL_USER_PASSWORD" ]; then
  echo "MYSQL_USER_PASSWORD is not set"
  exit 1
fi

kubectl create secret generic mysql -n taskapp --dry-run=client -o yaml \
  --from-literal=root_password=$MYSQL_ROOT_PASSWORD \
  --from-literal=user_password=$MYSQL_USER_PASSWORD | tee ./mysql-secret.yaml
