#!/bin/bash

source ./getEnv.sh

# Get Client Uid
source ./getClientUid.sh $1

# GET /{realm}/clients/{id}/default-client-scopes
curl -X GET "${KEYCLOAK_REST_URL}/clients/${CID}/default-client-scopes" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN"  | jq . 

