# Govern an MCP server with Ekam (RFC 9728)

Advertise Ekam as your MCP server's **authorization server** so agents discover how to get a
token. Serve this at `GET /.well-known/oauth-protected-resource` on your MCP server:

```json
{
  "resource": "https://mcp.example.com",
  "authorization_servers": ["https://ekam.olakrutrim.com"],
  "bearer_methods_supported": ["header"]
}
```

The agent then:
1. reads this Protected Resource Metadata,
2. fetches `https://ekam.olakrutrim.com/.well-known/oauth-authorization-server`,
3. obtains a scoped token from the broker, and
4. calls your MCP tools with `Authorization: Bearer <token>`.

Your MCP server verifies the token offline with `@krutrim/ekam-verify` (see `verify-gateway.ts`).
