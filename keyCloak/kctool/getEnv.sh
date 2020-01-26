#!/bin/bash

# config
export KEYCLOAK_URL=http://host02:8080/auth
export KEYCLOAK_REALM=demo
export KEYCLOAK_REST_URL=${KEYCLOAK_URL}/admin/realms/${KEYCLOAK_REALM}
export KEYCLOAK_CLIENT_ID=admin
export KEYCLOAK_CLIENT_SECRET=password

export TKN=$(curl -X POST "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
 -H "Content-Type: application/x-www-form-urlencoded" \
 -d "username=${KEYCLOAK_CLIENT_ID}" \
 -d "password=${KEYCLOAK_CLIENT_SECRET}" \
 -d 'grant_type=password' \
 -d 'client_id=admin-cli' | jq -r '.access_token')

