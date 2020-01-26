#!/bin/bash

source ./getEnv.sh

# Get Client Scope Uid
CSID=$(curl -X GET "${KEYCLOAK_REST_URL}/client-scopes" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  | jq --arg a "$1" -r 'map(select(.name == $a)) | .[].id') 

# GET /{realm}/client-scopes/{id}/scope-mappings/realm
curl -X GET "${KEYCLOAK_REST_URL}/client-scopes/${CSID}/scope-mappings/realm" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq . 

