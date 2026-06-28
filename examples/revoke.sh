#!/usr/bin/env bash
# Kill-switch — revoke a compromised agent. Any gateway calling introspection
# sees it inactive within seconds; offline verifiers see it at next token expiry.
set -euo pipefail
BASE="${EKAM_BASE:-https://ekam.olakrutrim.com}"
: "${OWNER_KEY:?set OWNER_KEY}"; : "${AGENT_ID:?set AGENT_ID (agt_...)}"

curl -s -X POST "$BASE/v1/agents/$AGENT_ID/revoke" -H "authorization: Bearer $OWNER_KEY" | jq .
# Confirm any token it holds now introspects inactive:
# curl -s "$BASE/oauth/introspect" -H 'content-type: application/json' -d '{"token":"<jwt>"}'  # -> {"active":false}
