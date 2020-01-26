#!/bin/bash

source ./getEnv.sh

curl -X GET "${KEYCLOAK_REST_URL}/components?parent=$1&type=org.keycloak.storage.UserStorageProvider" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq . 
