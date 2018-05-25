#!/bin/bash

container=$1
functionname=$2
subscription_id=$3

az account set --subscription $subscription_id

terraform init
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