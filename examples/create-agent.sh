#!/usr/bin/env bash
# Human-rooted agent creation (open beta). Every agent is owned by a human — there is NO anonymous
# agent signup. A person signs in, creates a workspace + key, then mints agents with that owner key.
# Docs: https://ekam.olakrutrim.com/docs#create-agents  ·  Agents: https://ekam.olakrutrim.com/llms-full.txt
set -euo pipefail

BASE="${EKAM_BASE:-https://ekam.olakrutrim.com}"
GATEWAY="${GATEWAY:-https://your-gateway.example}"

# Prereq: sign in at $BASE/account (any Google account in open beta), create a workspace, and copy the
# workspace key (ekam_sk_…). It represents YOU, the owner — export it as OWNER_KEY.
: "${OWNER_KEY:?set OWNER_KEY to your workspace key from $BASE/account}"

# 1. Define a blueprint (scopes, audience, TTL).
bp=$(curl -s "$BASE/v1/blueprints" -H "authorization: Bearer $OWNER_KEY" -H 'content-type: application/json' -d "{
    \"name\": \"chat-bot\",
    \"scopes\": [\"models:invoke\", \"models:read\"],
    \"allowedAudiences\": [\"$GATEWAY\"],
    \"tokenTtlSeconds\": 900
  }")
BP_ID=$(echo "$bp" | sed -n 's/.*"id":"\(bp_[^"]*\)".*/\1/p')

# 2. Mint an agent from the blueprint (owned by you).
agent=$(curl -s "$BASE/v1/agents" -H "authorization: Bearer $OWNER_KEY" -H 'content-type: application/json' \
  -d "{\"blueprintId\":\"$BP_ID\",\"name\":\"support-bot\"}")
AGENT_ID=$(echo "$agent" | sed -n 's/.*"id":"\(agt_[^"]*\)".*/\1/p')

# 3. Broker a short-lived, scoped token for the agent.
curl -s "$BASE/oauth/token" -H "authorization: Bearer $OWNER_KEY" -H 'content-type: application/json' -d "{
    \"grant_type\": \"urn:ietf:params:oauth:grant-type:token-exchange\",
    \"agent_id\": \"$AGENT_ID\",
    \"resource\": \"$GATEWAY\",
    \"scope\": \"models:invoke\"
  }"
# -> { "access_token": "<ES256 JWT>", "token_type": "Bearer", "expires_in": 900, "aud": "<gateway>" }
#
# Your gateway verifies that token OFFLINE against $BASE/.well-known/jwks.json — no call back to Ekam.
# Note: Ekam throttles (slows) under heavy load and never returns 429; honor the x-ekam-throttled-ms header.
