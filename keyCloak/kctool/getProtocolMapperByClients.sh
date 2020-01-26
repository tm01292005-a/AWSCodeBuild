#!/bin/bash

source ./getEnv.sh

# Get Client Uid
source ./getClientUid.sh $1

# GET CLIENT_PROTOCOL_MAPPER_ID
CPMID=$(curl -X GET "${KEYCLOAK_REST_URL}/clients/${CID}/protocol-mappers/models" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  | jq  --arg a "$2" -r 'map(select(.name == $a)) | .[].id' | sed "s/\"//g")

# GET /{realm}/client/{id}/protocol-mappers/models/{id}
curl -X GET "${KEYCLOAK_REST_URL}/clients/${CID}/protocol-mappers/models/${CPMID}" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq . 

