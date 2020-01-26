#!/bin/bash

source ./getEnv.sh

#
# config
#
# Client ID
CLIENT_ID=account
# Client Role Name to be added
ROLE_NAME=admin

# Get Client Uid
source ./getClientUid.sh ${CLIENT_ID}

# Get Role Data
ROLE_JSON=$(curl -X GET "${KEYCLOAK_REST_URL}/clients/${CID}/scope-mappings/realm/available" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  | jq --arg a "${ROLE_NAME}" -r '[ map(select(.name == $a)) | .[] ]') 

# GET /{realm}/clients/{id}/scope-mappings/realm
./getScopeMappingsByClients.sh ${CLIENT_ID} > before.txt

# POST /{realm}/clients/{id}/scope-mappings/realm
curl -XPOST "${KEYCLOAK_REST_URL}/clients/${CID}/scope-mappings/realm" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  -d "$ROLE_JSON"

# GET /{realm}/clients/{id}/scope-mappings/realm
./getScopeMappingsByClients.sh ${CLIENT_ID} > after.txt

# Check difference
diff before.txt after.txt

