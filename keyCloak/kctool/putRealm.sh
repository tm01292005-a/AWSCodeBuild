#!/bin/bash

source ./getEnv.sh

if [ $# -ne 1 ]; then
    echo "Usage: $0 <JsonFile>"
    exit 1
fi
json=`cat ./$1`

# GET /{realm}
./getRealm.sh $1 > before.txt

# PUT /{realm}
curl -X PUT "${KEYCLOAK_REST_URL}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  -d "$json"

# GET /{realm}
./getRealm.sh $1 > after.txt

# Check difference
diff before.txt after.txt

