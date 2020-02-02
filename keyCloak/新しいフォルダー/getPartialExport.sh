#!/bin/bash

source ./getEnv.sh

# GET /{realm}
curl -X POST "http://host02:8080/auth/admin/realms/demo/partial-export?exportClients=true&exportGroupsAndRoles=true" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq .

curl -X GET "http://host02:8080/auth/admin/realms/demo/users" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TKN" | jq .
