#!/bin/bash

source ./getEnv.sh

#
# config
#
# Client ID
CLIENT_ID=account
# Client Scope Name 
CLIENT_SCOPE_ID=profile

if [ $# -ne 1 ]; then
    echo "引数が足りません"
    exit 1
fi

json=`cat ./$1`

#  Get Client Uid
CID=$(curl -X GET "${KEYCLOAK_REST_URL}/clients?clientId=${CLIENT_ID}" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq .[].id | sed "s/\"//g")

# Get Client Scope Uid
CSID=$(curl -X GET "${KEYCLOAK_REST_URL}/client-scopes" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  | jq  --arg a "${CLIENT_SCOPE_ID}" -r 'map(select(.name == $a)) | .[].id')

# GET /{realm}/client/{id}/protocol-mappers/models
curl -X GET "${KEYCLOAK_REST_URL}/clients/${CID}/protocol-mappers/models" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq . > before.txt 

# POST /{realm}/clients/{id}/protocol-mappers/models 
curl -X POST "${KEYCLOAK_REST_URL}/clients/${CID}/protocol-mappers/models" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  -d "$json"

# GET /{realm}/client/{id}/protocol-mappers/models
curl -X GET "${KEYCLOAK_REST_URL}/clients/${CID}/protocol-mappers/models" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq . > after.txt 

# Check difference
diff before.txt after.txt

