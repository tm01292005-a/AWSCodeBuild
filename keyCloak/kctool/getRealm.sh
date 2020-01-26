#!/bin/bash

source ./getEnv.sh

# GET /{realm}
curl -X GET "${KEYCLOAK_REST_URL}" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq . 

