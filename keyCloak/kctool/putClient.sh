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

# GET /{realm}/clients/{CID}
./getClient.sh ${CLIENT_ID} > before.txt

# PUT /{realm}/clients
curl -X PUT "${KEYCLOAK_REST_URL}/clients/${CID}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  -d "$json"

# GET /{realm}/clients/{CID}
./getClient.sh ${CLIENT_ID} > after.txt

# Get Client Uid
diff before.txt after.txt

