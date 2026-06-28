#!/usr/bin/env bash
# Cross-app delegation with ID-JAG — carry a verified identity from app A to app B
# without re-authenticating. tenant + entity are preserved end to end.
set -euo pipefail
BASE="${EKAM_BASE:-https://ekam.olakrutrim.com}"

# App A exchanges its token for an ID-JAG (identity assertion) scoped to app B.
JAG=$(curl -s "$BASE/oauth/token" -H 'content-type: application/json' -d '{
  "grant_type":"urn:ietf:params:oauth:grant-type:token-exchange",
  "requested_token_type":"urn:ietf:params:oauth:token-type:id-jag",
  "subject_token":"'"${APP_A_TOKEN:?set APP_A_TOKEN}"'",
  "audience":"https://app-b.example" }' | jq -r .access_token)

# App B redeems the ID-JAG (jwt-bearer) for a local access token.
curl -s "$BASE/oauth/token" -H 'content-type: application/json' -d '{
  "grant_type":"urn:ietf:params:oauth:grant-type:jwt-bearer",
  "assertion":"'"$JAG"'" }' | jq .
