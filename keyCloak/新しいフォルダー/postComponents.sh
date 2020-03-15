#!/bin/bash

source ./getEnv.sh

#
# config
#
# Client ID
CLIENT_ID=account

if [ $# -ne 1 ]; then
    echo "ˆø”‚ª‘«‚è‚Ü‚¹‚ñ"
    exit 1
fi

json=`cat ./$1`

# GET /{realm}/components
curl -X GET "${KEYCLOAK_REST_URL}/components" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq . > before.txt

# POST /{realm}/components
curl -X POST "${KEYCLOAK_REST_URL}/components" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  -d "$json"

# GET /{realm}/components
curl -X GET "${KEYCLOAK_REST_URL}/components" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq . > after.txt

# Check difference
diff before.txt after.txt
