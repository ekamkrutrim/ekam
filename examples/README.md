# Examples

Runnable samples for [Krutrim Ekam](https://ekam.olakrutrim.com). Browse them rendered at
[ekam.olakrutrim.com/cookbook](https://ekam.olakrutrim.com/cookbook).

| File | What it shows |
|------|----------------|
| `verify-gateway.ts` | Verify an Ekam token offline in a gateway (the `@krutrim/ekam-verify` SDK). |
| `provision-and-broker.sh` | Owner key → blueprint → agent → brokered token (curl). |
| `govern-mcp.md` | Make Ekam your MCP server's authorization server (RFC 9728). |
| `idjag.sh` | Cross-app delegation with ID-JAG (issue + redeem). |
| `sso.html` | Add Ola Google SSO to a web app. |
| `revoke.sh` | Kill-switch: revoke a compromised agent. |

Most scripts need either an **owner API key** (`OWNER_KEY=ekam_sk_...`, from the console) or a
token; the SSO and MCP samples need no secret. Set `EKAM_BASE` to point at a different host.
