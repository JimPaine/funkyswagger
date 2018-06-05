#!/bin/bash

container=$1
functionname=$2
subscription_id=$3
backend_storage_account=$4
backend_storage_container=$5
backend_storage_access_key=$6
backend_key=$7

az account set --subscription $subscription_id

terraform init \
    -backend-config="storage_account_name=$backend_storage_account" \
    -backend-config="container_name=$backend_storage_container" \
    -backend-config="access_key=$backend_storage_access_key" \
    -backend-config="key=$backend_key"

terraform apply -auto-approve \
    -var "subscription_id=$subscription_id" \
    -var "container=$container" \
    -var "functionname=$functionname"

npm i swagger-ui-dist

connectionstring=$(terraform output -json primary_connection_string | jq '.value')
# strip out quotes left from json parse got to be a better way to do this
connectionstring="${connectionstring%\"}"
connectionstring="${connectionstring#\"}"

az storage blob upload-batch \
    --source ./node_modules/swagger-ui-dist/ \
    --destination $container \
    --connection-string $connectionstring \
    --type block

storage=$(terraform output -json storage_connection_string | jq '.value')
# strip out quotes left from json parse got to be a better way to do this
storage="${storage%\"}"
storage="${storage#\"}"

cp temp-proxies.json proxies.json
sed -i "s|{bloblocation}|$storage$container|g" proxies.json

az storage file upload \
    --share-name "$functionname-content/site/wwwroot" \
    --source proxies.json \
    --connection-string $connectionstring

rm proxies.json
rm -rf node_modules