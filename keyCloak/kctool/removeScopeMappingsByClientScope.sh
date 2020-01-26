#!/bin/bash

source ./getEnv.sh

#
# config
#
# Client ID
CLIENT_ID=account
# Client Scope Name 
CLIENT_SCOPE_NAME=address
# Client Role Name to be deleted
ROLE_NAME=admin

# Get Client Scope Uid
CSID=$(curl -X GET "${KEYCLOAK_REST_URL}/client-scopes" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  | jq --arg a "${CLIENT_SCOPE_NAME}" -r 'map(select(.name == $a)) | .[].id') 

# Get Role Data
ROLE_JSON=$(curl -X GET "${KEYCLOAK_REST_URL}/client-scopes/${CSID}/scope-mappings/realm" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  | jq --arg a "${ROLE_NAME}" -r '[ map(select(.name == $a)) | .[] ]')

# GET /{realm}/client-scopes/{id}/scope-mappings/realm
curl -X GET "${KEYCLOAK_REST_URL}/client-scopes/${CSID}/scope-mappings/realm" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq . > before.txt 

# POST /{realm}/client-scopes/{id}/scope-mappings/realm
curl -X DELETE "${KEYCLOAK_REST_URL}/client-scopes/${CSID}/scope-mappings/realm" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  -d "$ROLE_JSON"

# GET /{realm}/client-scopes/{id}/scope-mappings/realm
curl -X GET "${KEYCLOAK_REST_URL}/client-scopes/${CSID}/scope-mappings/realm" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq . > after.txt 

# Check difference
diff before.txt after.txt

