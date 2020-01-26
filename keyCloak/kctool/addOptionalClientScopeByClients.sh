#!/bin/bash

source ./getEnv.sh

#
# config
#
# Client ID
CLIENT_ID=account
# Client Scope Id
CLIENT_SCOPE_ID=profile

# Get Client Uid
source ./getClientUid.sh ${CLIENT_ID}

# Get Client Scope Uid
CSID=$(curl -X GET "${KEYCLOAK_REST_URL}/client-scopes" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  | jq  --arg a "${CLIENT_SCOPE_ID}" -r 'map(select(.name == $a)) | .[].id') 

# GET /{realm}/clients/{id}/optional-client-scopes
./getOptionalClientScopeByClients.sh ${CLIENT_ID} > before.txt

# PUT /{realm}/clients/{id}/optional-client-scopes/{clientScopeId}
curl -X PUT "${KEYCLOAK_REST_URL}/clients/${CID}/optional-client-scopes/${CSID}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" 

# GET /{realm}/clients/{id}/optional-client-scopes
./getOptionalClientScopeByClients.sh ${CLIENT_ID} > after.txt

# Check difference
diff before.txt after.txt

