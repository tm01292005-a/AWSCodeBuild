#!/bin/bash

source ./getEnv.sh

# GET /{realm}
curl -X GET "http://host02:8080/auth/realms/master/export/realm" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq .
