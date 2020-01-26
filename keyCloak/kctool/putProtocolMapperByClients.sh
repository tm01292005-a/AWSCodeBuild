#!/bin/bash

source ./getEnv.sh

#
# config
#
# Client ID
CLIENT_ID=account
# Client Scope Id 
CLIENT_SCOPE_ID=profile
# Client Peotocol Mapper Name
CLIENT_PROTOCOL_MAPPER_NAME='Client ID2'

if [ $# -ne 1 ]; then
    echo "引数が足りません"
    exit 1
fi

json=`cat ./$1`

# Get Client Uid
source ./getClientUid.sh ${CLIENT_ID}

# GET CLIENT_PROTOCOL_MAPPER_ID
CPMID=$(curl -X GET "${KEYCLOAK_REST_URL}/clients/${CID}/protocol-mappers/models" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  | jq  --arg a "${CLIENT_PROTOCOL_MAPPER_NAME}" -r 'map(select(.name == $a)) | .[].id' | sed "s/\"//g")

# GET /{realm}/client/{id}/protocol-mappers/models/{id}
./getProtocolMapperByClients.sh ${CLIENT_ID} '${CLIENT_PROTOCOL_MAPPER_NAME}' > before.txt
#curl -X GET "${KEYCLOAK_REST_URL}/clients/${CID}/protocol-mappers/models/${CPMID}" \
#  -H "Accept: application/json" \
#  -H "Authorization: Bearer $TKN" | jq . > before.txt 

# PUT /{realm}/clients/{id}/protocol-mappers/models/{id}
curl -X PUT "${KEYCLOAK_REST_URL}/clients/${CID}/protocol-mappers/models/${CPMID}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" \
  -d "$json"

# GET /{realm}/client/{id}/protocol-mappers/models/{id}
./getProtocolMapperByClients.sh ${CLIENT_ID} '${CLIENT_PROTOCOL_MAPPER_NAME}' >  after.txt
#curl -X GET "${KEYCLOAK_REST_URL}/clients/${CID}/protocol-mappers/models/${CPMID}" \
#  -H "Accept: application/json" \
#  -H "Authorization: Bearer $TKN" | jq . > after.txt 

# Check difference
diff before.txt after.txt

