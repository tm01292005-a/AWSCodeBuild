#!/bin/bash

source ./getEnv.sh

# GET /{realm}/client-scopes
curl -X GET "${KEYCLOAK_REST_URL}/client-scopes" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq . 

