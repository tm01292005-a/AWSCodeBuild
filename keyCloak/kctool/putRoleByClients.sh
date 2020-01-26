#!/bin/bash

source ./getEnv.sh

#
# config
#
# Client ID
CLIENT_ID=account
# Role Name
ROLE_NAME='bbb'

if [ $# -ne 1 ]; then
    echo "引数が足りません"
    exit 1
fi

json=`cat ./$1`

# Get Client Uid
source ./getClientUid.sh ${CLIENT_ID}

# GET /{realm}/clients/{id}/roles/{role-name}
curl -X GET "${KEYCLOAK_REST_URL}/clients/${CID}/roles/${ROLE_NAME}" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq . > before.txt

# PUT /{realm}/clients/{id}/roles/{role-name} 
curl -X PUT "${KEYCLOAK_REST_URL}/clients/${CID}/roles/${ROLE_NAME}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  -d "$json"

# GET /{realm}/clients/{id}/roles/{role-name}
curl -X GET "${KEYCLOAK_REST_URL}/clients/${CID}/roles/${ROLE_NAME}" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq . > after.txt 

# Check difference
diff before.txt after.txt

