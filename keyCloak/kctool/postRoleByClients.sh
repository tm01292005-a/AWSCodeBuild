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

# Get Client Uid
source ./getClientUid.sh ${CLIENT_ID}

# GET /{realm}/clients/{id}/roles
./getRoleByClients.sh ${CLIENT_ID} > before.txt

# POST /{realm}/clients/{id}/roles
curl -X POST "${KEYCLOAK_REST_URL}/clients/${CID}/roles" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  -d "$json"

# GET /{realm}/clients?clientId={clientId}
./getRoleByClients.sh ${CLIENT_ID} > after.txt

# Check difference
diff before.txt after.txt

