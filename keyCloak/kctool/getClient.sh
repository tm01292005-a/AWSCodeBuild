#!/bin/bash

source ./getEnv.sh

curl -X GET "${KEYCLOAK_REST_URL}/clients?clientId=$1" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq . 
