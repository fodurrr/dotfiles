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
EXAMPLE_API_TOKEN=replace_me
```

## Secure Setup

```bash
mkdir -p ~/.config/secrets
chmod 700 ~/.config/secrets
cp ~/dev/dotfiles/.env.ai.example ~/.config/secrets/ai.env
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

Sync managed AI vars to launchd for GUI apps (macOS only; the managed list in `.zshrc` is currently empty):

```bash
ai-env-sync
```

Login shells run this sync automatically once per shell startup.

## Verify

Shell env:

```bash
printenv EXAMPLE_API_TOKEN
```

launchd env (GUI-visible after sync, for names in the managed list):

```bash
launchctl getenv EXAMPLE_API_TOKEN
```

## Caveat

GUI apps launched before first login-shell sync may not see updated vars yet.
Run `ai-env-sync` manually after changing `ai.env` if needed.
