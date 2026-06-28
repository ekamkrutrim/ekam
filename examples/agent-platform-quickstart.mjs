// =============================================================================
// Krutrim Ekam — agent-platform integration quickstart
//
// USE CASE: An agent platform needs every agent it runs to carry a verifiable
// identity so a gateway (e.g. an AI model gateway) can gate, meter, and bill the owner.
//
// ALL THE PLATFORM NEEDS FROM EKAM IS ONE SECRET: an **owner API key**
// (ekam_sk_...). The Ekam operator creates an Owner for the platform (one click in
// the console, or `POST /v1/owners` with the admin token) and hands over that one
// key. With it, the platform self-serves everything below over plain HTTPS — no
// other secret, no SDK.
//
// RUN:
//   OWNER_KEY=ekam_sk_xxx node examples/agent-platform-quickstart.mjs
//
// (Node 18+; uses global fetch. Set EKAM_BASE to override the host.)
// =============================================================================

const EKAM = process.env.EKAM_BASE || "https://ekam.olakrutrim.com";
const OWNER_KEY = process.env.OWNER_KEY;                 // the ONE secret the platform holds
const AUDIENCE = process.env.AUDIENCE || "https://your-gateway.example";

if (!OWNER_KEY) { console.error("set OWNER_KEY=ekam_sk_... (your Ekam owner key)"); process.exit(1); }

// Small helper: every Ekam call is Bearer <owner key> + JSON.
async function ekam(method, path, body) {
  const r = await fetch(EKAM + path, {
    method,
    headers: { authorization: `Bearer ${OWNER_KEY}`, "content-type": "application/json" },
    body: body ? JSON.stringify(body) : undefined,
  });
  const j = await r.json().catch(() => ({}));
  if (!r.ok) throw new Error(`${method} ${path} -> ${r.status} ${j.error_description || j.error || ""}`);
  return j;
}

// ---- 1) ONE-TIME: define what the platform's agents may do, then provision one. ----
// A *blueprint* is the policy template (scopes, audiences, classification, cost
// center). An *agent* is an instance of it. Do this once per agent and store the id.
async function provisionAgent(name) {
  const blueprint = await ekam("POST", "/v1/blueprints", {
    name: "platform-agent",
    scopes: ["models:invoke", "models:chat"],
    allowedAudiences: [AUDIENCE],
    tokenTtlSeconds: 900,            // tokens live 15 min
    // maxClassification: "bu-confidential",  // optional ceiling the gateway enforces
    // costCenter: "PLATFORM",                // optional — gateway meters/bills against this
  });
  const agent = await ekam("POST", "/v1/agents", { blueprintId: blueprint.id, name });
  return agent.id;                   // agt_... — persist this in your platform
}

// ---- 2) PER-CALL: exchange the owner key for a short-lived agent token. ----
// Call this right before a batch of model calls. The token is bound to the audience
// and expires; the gateway verifies it OFFLINE against Ekam's JWKS.
async function mintAgentToken(agentId) {
  const t = await ekam("POST", "/oauth/token", {
    agent_id: agentId,
    audience: AUDIENCE,
    scope: "models:chat",
  });
  return t.access_token;             // present as `Authorization: Bearer <token>` to the gateway
}

// ---- 3) The agent calls the gateway with the token (the gateway bills the owner). ----
async function callGateway(token) {
  // Illustrative — your real gateway endpoint/payload:
  // return fetch(`${AUDIENCE}/v1/chat/completions`, {
  //   method: "POST",
  //   headers: { authorization: `Bearer ${token}`, "content-type": "application/json" },
  //   body: JSON.stringify({ model: "krutrim-2", messages: [{ role: "user", content: "hi" }] }),
  // });
  return { note: "send this token as Bearer to your gateway; it verifies + meters + bills the owner" };
}

// ---- demo ----
const agentId = await provisionAgent("platform-support-bot");
console.log("provisioned agent:", agentId);

const token = await mintAgentToken(agentId);
const claims = JSON.parse(Buffer.from(token.split(".")[1], "base64url").toString());
console.log("minted token claims:", {
  sub: claims.sub, type: claims.type, aud: claims.aud, scope: claims.scope,
  tenant: claims.tenant, entity: claims.entity, owner: claims.parent || claims.owner,
  exp: new Date(claims.exp * 1000).toISOString(),
});

console.log("call gateway:", await callGateway(token));
console.log("\n✅ one owner key → provision agent → mint token → call gateway. That's the whole loop.");

// Need to cut an agent off instantly?  POST /v1/agents/<agt_id>/revoke  (Bearer owner key)
