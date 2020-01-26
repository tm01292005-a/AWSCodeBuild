#!/bin/bash

source ./getEnv.sh

#
# config
#
# Client ID
CLIENT_ID=account

if [ $# -ne 1 ]; then
    echo "引数が足りません"
    exit 1
fi

json=`cat ./$1`

# GET /{realm}/clients?clientId={clientId}
curl -X GET "${KEYCLOAK_REST_URL}/clients?clientId=${CLIENT_ID}" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq . > before.txt

# POST /{realm}/clients
curl -X POST "${KEYCLOAK_REST_URL}/clients" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  -d "$json"

# GET /{realm}/clients?clientId={clientId}
curl -X GET "${KEYCLOAK_REST_URL}/clients?clientId=${CLIENT_ID}" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq . > after.txt 

# Check difference
diff before.txt after.txt

