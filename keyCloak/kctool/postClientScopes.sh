#!/bin/bash

source ./getEnv.sh

if [ $# -ne 1 ]; then
    echo "引数が足りません"
    exit 1
fi

json=`cat ./$1`

# GET /{realm}/client-scopes
./getClientScopes.sh > before.txt

# POST /{realm}/client-scopes 
curl -X POST "${KEYCLOAK_REST_URL}/client-scopes" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  -d "$json"

# GET /{realm}/client-scopes
./getClientScopes.sh > after.txt

# Check difference
diff before.txt after.txt

