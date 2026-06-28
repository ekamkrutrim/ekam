#!/usr/bin/env bash
# Provision an agent and broker a short-lived, audience-bound token — three calls.
#
#   OWNER_KEY=ekam_sk_... ./examples/provision-and-broker.sh
#
set -euo pipefail
BASE="${EKAM_BASE:-https://ekam.olakrutrim.com}"
: "${OWNER_KEY:?set OWNER_KEY to your ekam_sk_... owner API key}"

# 1) A blueprint = the policy template an agent is minted from.
BP=$(curl -s "$BASE/v1/blueprints" -H "authorization: Bearer $OWNER_KEY" -H 'content-type: application/json' \
  -d '{"name":"support","scopes":["models:invoke"],"allowedAudiences":["https://your-gateway.example"],"tokenTtlSeconds":900}' \
  | jq -r .id)
echo "blueprint: $BP"

# 2) An agent = an instance of that blueprint.
AG=$(curl -s "$BASE/v1/agents" -H "authorization: Bearer $OWNER_KEY" -H 'content-type: application/json' \
  -d "{\"blueprintId\":\"$BP\",\"name\":\"support-bot\"}" | jq -r .id)
echo "agent: $AG"

# 3) Broker a token the agent presents to your gateway (any audience it is allowed).
curl -s "$BASE/oauth/token" -H "authorization: Bearer $OWNER_KEY" -H 'content-type: application/json' \
  -d "{\"grant_type\":\"urn:ietf:params:oauth:grant-type:token-exchange\",\"agent_id\":\"$AG\",\"resource\":\"https://your-gateway.example\",\"scope\":\"models:invoke\"}" | jq .
