# Global AI Secrets

Portable machine-local setup for AI credentials used by CLI and desktop tools.

## File Location

Use this file outside repositories:

- `~/.config/secrets/ai.env`

Environment override (optional):

- `DOTFILES_AI_ENV_FILE=/custom/path/to/ai.env`

## File Format

Use plain `KEY=value` lines (no quotes required unless value needs them).

Example:

```bash
# Required global contract (no auggie dependency):
AUGMENT_API_TOKEN=replace_me
AUGMENT_API_URL=https://d15.api.augmentcode.com

# Optional advanced override: explicit Authorization header value
# AUGMENT_MCP_CONTEXT_ENGINE_AUTHORIZATION=Bearer replace_me

# Optional advanced override: explicit endpoint URL (takes precedence over AUGMENT_API_URL)
# AUGMENT_MCP_CONTEXT_ENGINE_URL=https://api.augmentcode.com/mcp

# Optional endpoint/header overrides:
# AUGMENT_MCP_CONTEXT_ENGINE_HEADERS_JSON={"x-example":"value"}
# AUGMENT_MCP_CONTEXT_ENGINE_APP_ID=replace_me
# AUGMENT_MCP_CONTEXT_ENGINE_DEPLOYMENT_URL=https://example.com
# AUGMENT_MCP_CONTEXT_ENGINE_TRANSPORT=sse
```

## Secure Setup

```bash
mkdir -p ~/.config/secrets
chmod 700 ~/.config/secrets
cp /Users/fodurrr/dev/dotfiles/.env.ai.example ~/.config/secrets/ai.env
chmod 600 ~/.config/secrets/ai.env
```

Edit your real values:

```bash
zed ~/.config/secrets/ai.env
```

## Load and Sync

Reload shell (loads env file):

```bash
source ~/.zshrc
```

Sync managed AI vars to launchd for GUI apps:

```bash
ai-env-sync
```

Login shells run this sync automatically once per shell startup.

## Verify

Shell env:

```bash
printenv AUGMENT_API_TOKEN AUGMENT_API_URL
```

launchd env (GUI-visible after sync):

```bash
launchctl getenv AUGMENT_API_TOKEN
launchctl getenv AUGMENT_API_URL
```

MCP preflight (routing + auth):

```bash
elixir /Users/fodurrr/dev/xpando-agents/mcp_tools/mcp_eval.exs 'MCPClient.list_servers()'
elixir /Users/fodurrr/dev/xpando-agents/mcp_tools/mcp_eval.exs 'MCPTools.AugmentContextEngine.codebase_retrieval()'
```

## Caveat

GUI apps launched before first login-shell sync may not see updated vars yet.
Run `ai-env-sync` manually after changing `ai.env` if needed.
