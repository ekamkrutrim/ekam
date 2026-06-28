// Verify an Ekam token in your gateway.
//
//   npm i @krutrim/ekam-verify
//   EKAM_TOKEN=<jwt> npx tsx examples/verify-gateway.ts
//
// The verifier fetches the JWKS once and validates tokens OFFLINE (signature, issuer,
// audience, expiry). Pass `introspectUrl` to also honour the live kill-switch.
import { createEkamVerifier } from "@krutrim/ekam-verify";

const verify = createEkamVerifier({
  issuer: "https://ekam.olakrutrim.com",
  jwksUri: "https://ekam.olakrutrim.com/.well-known/jwks.json",
  audience: "https://api.bharatrouter.com",
  introspectUrl: "https://ekam.olakrutrim.com/oauth/introspect", // optional live revocation
});

// Express-style middleware
export async function ekamGate(req: any, res: any, next: any) {
  try {
    const principal = await verify(req.headers.authorization?.split(" ")[1]);
    req.principal = principal; // { agentId, ownerId, scopes, tenant, entity, maxClassification, costCenter }
    if (!principal.scopes.includes("models:invoke")) return res.status(403).end();
    next();
  } catch {
    res.status(401).end();
  }
}

// Run standalone against a token in $EKAM_TOKEN
if (process.env.EKAM_TOKEN) {
  verify(process.env.EKAM_TOKEN)
    .then((p) => console.log("valid principal:", p))
    .catch((e) => { console.error("rejected:", e.message); process.exit(1); });
}
