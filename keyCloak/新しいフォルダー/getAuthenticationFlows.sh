#!/bin/bash

source ./getEnv.sh

# GET /{realm}/authentication/flows
curl -X GET "${KEYCLOAK_REST_URL}/authentication/flows" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq .
