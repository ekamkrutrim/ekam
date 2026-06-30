<p align="center">
  <img src="assets/logo.png" alt="Krutrim Ekam" width="96" height="96">
</p>

<h1 align="center">Krutrim <span>Ekam</span></h1>
<p align="center"><b>India's agent-identity &amp; access control plane.</b><br>
Every AI agent gets a real, owned identity — not a shared API key.</p>

<p align="center">
  <a href="https://ekam.olakrutrim.com"><b>Open beta — start free</b></a> ·
  <a href="https://ekam.olakrutrim.com/blog">Blog</a> ·
  <a href="https://ekam.olakrutrim.com/docs">Docs &amp; API</a> ·
  <a href="https://ekam.olakrutrim.com/cookbook">Cookbook</a> ·
  <a href="https://ekam.olakrutrim.com/llms.txt">llms.txt</a> ·
  <a href="https://ekam.olakrutrim.com/privacy">Privacy</a> ·
  <a href="https://ekam.olakrutrim.com/terms">Terms</a>
</p>

---

## What is Ekam?

**Ekam** (एकम् — "one") is an OAuth 2.1 / OIDC authorization server purpose-built for the
agent era. It gives every principal — a **human** who signs in, or an **agent** that runs
unattended — a single, verifiable identity, and it brokers **short-lived, audience-bound,
delegated tokens** that downstream services (gateways, MCP servers, APIs) verify **offline**.

AI agents today authenticate with long-lived API keys — unscoped, unattributable, and impossible to
revoke cleanly. As agents come to outnumber human users, that doesn't scale and it isn't safe. Ekam
replaces the shared key with a real identity: **least-privilege, attributable, instantly containable,
and accountable under Indian law (DPDP)**. It's the trust layer for building **reliable AI and agents**
— and it's India's own, standards-based and under our own jurisdiction.

Ekam is **gateway-neutral**: it issues the identity and token, and any AI gateway, MCP server, or API
verifies it offline — not tied to any one gateway.

> 📰 Read the thesis: **[Why India needs its own agent-identity control plane](https://ekam.olakrutrim.com/blog/why-india-needs-an-agent-identity-control-plane)**

## Open beta

Ekam is **open beta — free, no invite**:

- **Humans** sign in with any Google account (or your org's OIDC / SAML / GitHub IdP).
- **Human-rooted agents** — a signed-in human creates a workspace and mints agents; every agent is
  **owned by a human**. There is **no anonymous agent signup** — that root of authority is the point.
- Agents can fan out scoped **sub-agents** under the same human's authority (delegation / `act` chain).
- Usage is metered; **billing is off** during beta.
- Requests are **throttled (slowed), never blocked** — the service stays up for everyone.

## Key features

- **Human-rooted agent identity** — every agent is owned, blueprinted, revocable, and traces to a
  human. Not an anonymous API key.
- **Offline verification** — ES256 JWTs + JWKS; gateways verify without calling home, with an
  optional live **kill-switch** via introspection (RFC 7662) + **CAEP push** (SSF).
- **Delegation that travels** — RFC 8693 token-exchange + **ID-JAG / Cross-App Access**: carry a
  verified identity from app A to app B, tenant &amp; entity preserved.
- **MCP on-ramp** — RFC 9728 Protected Resource Metadata so agents *discover* how to get a token.
- **Standards-native** — OAuth 2.1, OIDC, RFC 8414 / 9728 discovery, 8707 audience binding, 7662
  introspection, SCIM 2.0, CAEP/SSF. Bring your own IdP (OIDC/SAML/GitHub) and PDP (groot/OPA/OpenFGA/Cerbos).
- **Human + agent parity** — every capability ships as a human UI *and* a JSON/MCP API.
- **DPDP-native** — one canonical **Person** above every account and agent, so access &amp; erasure
  act on the whole person, not a fragment.
- **Built for India** — hosted on Krutrim Cloud, DR enabled, priced in INR.

## Two ways in

| Principal | How it authenticates |
|-----------|----------------------|
| **Human** | Sign in with any Google account at [ekam.olakrutrim.com](https://ekam.olakrutrim.com) (or your org's OIDC / SAML / GitHub IdP) → `type:human` token. The root of authority. |
| **Agent** | A signed-in human creates a workspace key, then mints agents (`POST /v1/agents`) and brokers tokens (`POST /oauth/token`). Agents fan out sub-agents via delegation (RFC 8693). Discover the AS via MCP (RFC 9728). |

## Quickstart — create a human-rooted agent

Sign in at [ekam.olakrutrim.com/account](https://ekam.olakrutrim.com/account) (any Google account in
open beta), create a workspace, and mint a workspace key (`ekam_sk_…`) — that key represents **you**,
the owner. Then:

```bash
BASE=https://ekam.olakrutrim.com   # OWNER_KEY = your workspace key from /account

# 1. Define a blueprint, then mint an agent (owned by you)
curl -s $BASE/v1/blueprints -H "authorization: Bearer $OWNER_KEY" -H 'content-type: application/json' \
  -d '{"name":"chat-bot","scopes":["models:invoke"],"allowedAudiences":["https://your-gateway.example"],"tokenTtlSeconds":900}'
curl -s $BASE/v1/agents -H "authorization: Bearer $OWNER_KEY" -H 'content-type: application/json' \
  -d '{"blueprintId":"bp_…","name":"support-bot"}'

# 2. Broker a short-lived, scoped token for the agent
curl -s $BASE/oauth/token -H "authorization: Bearer $OWNER_KEY" -H 'content-type: application/json' \
  -d '{"grant_type":"urn:ietf:params:oauth:grant-type:token-exchange","agent_id":"agt_…","resource":"https://your-gateway.example","scope":"models:invoke"}'
```

> **Why human-rooted?** An agent that bootstraps its own identity from nothing is exactly the
> anonymous, unaccountable credential Ekam exists to replace. Every agent traces to a human — that's
> what makes it attributable, revocable, and DPDP-accountable.

**Building an agent or tool?** Point it at [`/llms.txt`](https://ekam.olakrutrim.com/llms.txt) and
[`/llms-full.txt`](https://ekam.olakrutrim.com/llms-full.txt) — a machine-readable map and a full
self-serve quickstart.

## Sample code

This repo holds runnable samples — see [`examples/`](examples/). The same recipes are browsable at
[ekam.olakrutrim.com/cookbook](https://ekam.olakrutrim.com/cookbook) (no login required):

| Recipe | File |
|--------|------|
| Create a human-rooted agent → broker a token | [`examples/create-agent.sh`](examples/create-agent.sh) |
| Verify an Ekam token in your gateway (SDK) | [`examples/verify-gateway.ts`](examples/verify-gateway.ts) |
| Provision an agent &amp; broker a token (owner key) | [`examples/provision-and-broker.sh`](examples/provision-and-broker.sh) |
| Govern an MCP server with Ekam (RFC 9728) | [`examples/govern-mcp.md`](examples/govern-mcp.md) |
| Cross-app delegation with ID-JAG | [`examples/idjag.sh`](examples/idjag.sh) |
| Add Google SSO to your app | [`examples/sso.html`](examples/sso.html) |
| Kill-switch: revoke a compromised agent | [`examples/revoke.sh`](examples/revoke.sh) |

## Verify a token in one import

```ts
import { createEkamVerifier } from "@krutrim/ekam-verify";

const verify = createEkamVerifier({
  issuer: "https://ekam.olakrutrim.com",
  jwksUri: "https://ekam.olakrutrim.com/.well-known/jwks.json",
  audience: "https://your-gateway.example",
});

const principal = await verify(token); // { agentId, ownerId, scopes, tenant, entity, ... }
```

## Status

Live at **https://ekam.olakrutrim.com** · **open beta** · DR enabled. The control-plane source is
maintained privately by the Krutrim team; this repo is the public front door — samples, docs links,
and issue tracking.

## Contributing / feedback

- 🐞 [Report an issue](https://github.com/ekamkrutrim/ekam/issues/new?labels=bug&template=bug_report.md)
- 💡 [Request a feature](https://github.com/ekamkrutrim/ekam/issues/new?labels=enhancement&template=feature_request.md)

---

<p align="center"><sub>© Krutrim SI Designs Private Limited · a Krutrim group company · hosted on Krutrim Cloud (India)</sub></p>
