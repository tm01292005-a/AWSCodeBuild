#!/bin/bash

source ./getEnv.sh

curl -X GET "${KEYCLOAK_REST_URL}/components?type=org.keycloak.keys.KeyProvider" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq .
