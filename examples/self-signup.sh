#!/usr/bin/env bash
# Open beta: an agent registers ITSELF (no key needed), then brokers a scoped, short-lived token.
# Docs: https://ekam.olakrutrim.com/docs#self-signup  ·  Agents: https://ekam.olakrutrim.com/llms-full.txt
set -euo pipefail

BASE="${EKAM_BASE:-https://ekam.olakrutrim.com}"
GATEWAY="${GATEWAY:-https://your-gateway.example}"

# 1. Self-signup → owner_key + agent_id (the owner_key is shown once; store it securely).
signup=$(curl -s "$BASE/v1/agents/self-signup" -H 'content-type: application/json' -d "{
    \"name\": \"my-agent\",
    \"allowedAudiences\": [\"$GATEWAY\"],
    \"scopes\": [\"models:invoke\", \"models:read\"]
  }")
echo "$signup"

OWNER_KEY=$(echo "$signup" | sed -n 's/.*"owner_key":"\([^"]*\)".*/\1/p')
AGENT_ID=$(echo "$signup" | sed -n 's/.*"agent_id":"\([^"]*\)".*/\1/p')

# 2. Broker a token (owner_key is the OAuth client).
curl -s "$BASE/oauth/token" \
  -H "authorization: Bearer $OWNER_KEY" \
  -H 'content-type: application/json' \
  -d "{
    \"grant_type\": \"urn:ietf:params:oauth:grant-type:token-exchange\",
    \"agent_id\": \"$AGENT_ID\",
    \"resource\": \"$GATEWAY\",
    \"scope\": \"models:invoke\"
  }"
# -> { "access_token": "<ES256 JWT>", "token_type": "Bearer", "expires_in": 900, "aud": "<gateway>" }
#
# Your gateway verifies that token OFFLINE against $BASE/.well-known/jwks.json — no call back to Ekam.
# Note: Ekam throttles (slows) under heavy load and never returns 429; honor the x-ekam-throttled-ms header.
