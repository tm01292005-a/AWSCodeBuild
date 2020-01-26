#!/bin/bash

source ./getEnv.sh

# Get Client Uid
source ./getClientUid.sh $1

# GET /{realm}/clients/{id}/scope-mappings/realm
curl -X GET "${KEYCLOAK_REST_URL}/clients/${CID}/scope-mappings/realm" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq . 

