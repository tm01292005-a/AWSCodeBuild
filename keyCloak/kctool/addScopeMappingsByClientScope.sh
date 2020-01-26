#!/bin/bash

source ./getEnv.sh

#
# config
#
# Client ID
CLIENT_ID=account
# Client Scope Name
CLIENT_SCOPE_NAME=address
# Client Role Name to be added
ROLE_NAME=admin

# Get Client Scope Uid
CSID=$(curl -X GET "${KEYCLOAK_REST_URL}/client-scopes" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  | jq --arg a "${CLIENT_SCOPE_NAME}" -r 'map(select(.name == $a)) | .[].id') 

# Get Role Data
ROLE_JSON=$(curl -X GET "${KEYCLOAK_REST_URL}/client-scopes/${CSID}/scope-mappings/realm/available" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  | jq --arg a "${ROLE_NAME}" -r '[ map(select(.name == $a)) | .[] ]')

# GET /{realm}/client-scopes/{id}/scope-mappings/realm
./getScopeMappingsByClientScope.sh ${CLIENT_SCOPE_NAME} ${ROLE_NAME} > before.txt

# POST /{realm}/client-scopes/{id}/scope-mappings/realm
curl -XPOST "${KEYCLOAK_REST_URL}/client-scopes/${CSID}/scope-mappings/realm" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  -d "$ROLE_JSON"

# GET /{realm}/client-scopes/{id}/scope-mappings/realm
./getScopeMappingsByClientScope.sh  ${CLIENT_SCOPE_NAME} ${ROLE_NAME} > after.txt

# Check difference
diff before.txt after.txt

