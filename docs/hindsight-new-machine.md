# Hindsight memory on a new machine

`./install.sh` does **not** set up Hindsight memory. Do these steps once per
machine, after the dotfiles install. They are the steps used on Omen and Mini
on **2026-11-03**. Background and evidence: [personal Hindsight memory](hindsight-memory.md).

Run every command from GEEKOM. `{HOST}` is the new machine's SSH name, for
example `omen` or `mini`. Commands use `zsh -l -i` so mise tools are on the path.

## 0. Check the starting point

The dotfiles install must already provide the agent tools:

```sh
ssh {HOST} 'zsh -l -i -c "claude --version; codex --version; pi --version; grok --version; node --version"'
```

The machine must reach the Hindsight service on Mini. Expect `200`:

```sh
ssh {HOST} 'curl -s -o /dev/null -w "%{http_code}\n" https://peters-mac-mini.wisent-fence.ts.net/health'
```

For T3 Code use, the machine runs its own T3 server and is linked from GEEKOM.

## 1. Back up the files that change

```sh
ssh {HOST} 'J=~/.local/state/hindsight-host-rollout/$(date +%F); mkdir -p "$J" && chmod 700 "$J"
for f in .claude/settings.json .claude.json .codex/config.toml .codex/hooks.json .pi/agent/settings.json \
  .grok/config.toml .config/opencode/opencode.json .gemini/config/hooks.json .t3/userdata/settings.json; do
  [ -f "$HOME/$f" ] && mkdir -p "$J/$(dirname "$f")" && cp -p "$HOME/$f" "$J/$f"; done; ls -R "$J"'
```

## 2. Copy the Hindsight settings file

All machines use **one API token** (Peter's decision, 2026-11-03). The settings
file holds it, so copy the file; never paste the token into a command.

```sh
ssh {HOST} 'mkdir -p ~/.hindsight && chmod 700 ~/.hindsight'
scp -p ~/.hindsight/coding-agent.json {HOST}:.hindsight/coding-agent.json
ssh {HOST} 'chmod 600 ~/.hindsight/coding-agent.json'
```

## 3. Run the official installer

Name the agents. Do not use `all`: it also matches leftover folders.
Add `opencode2` only if `ssh {HOST} 'zsh -l -i -c "command -v opencode2"'` finds it.

```sh
ssh {HOST} 'zsh -l -i -c "mise exec node@lts -- npx -y @vectorize-io/hindsight-coding-agents@0.8.1 install claude-code codex pi grok-build opencode antigravity-cli --server self-hosted --api-url https://peters-mac-mini.wisent-fence.ts.net </dev/null"'
```

Expect `Installed 6 agents` (7 with `opencode2`).

## 4. Add the Claude `SessionEnd` entry

Without it, Claude saves only the question, not its final answer.

```sh
ssh {HOST} 'python3 -I -' <<'EOF'
import json, os
p = os.path.expanduser("~/.claude/settings.json")
d = json.load(open(p))
cmd = 'node "%s/.hindsight/coding-agents/dist/claude-stop-hook.js"' % os.path.expanduser("~")
se = d.setdefault("hooks", {}).setdefault("SessionEnd", [])
if not any(h.get("command") == cmd for g in se for h in g.get("hooks", [])):
    se.append({"hooks": [{"type": "command", "command": cmd, "timeout": 60}]})
    tmp = p + ".tmp"; json.dump(d, open(tmp, "w"), indent=2); os.replace(tmp, p)
print("SessionEnd ok")
EOF
```

## 5. Trust the Codex hooks

Codex runs new hooks only after you trust them. Start Codex once in a terminal:

```sh
ssh -t {HOST} 'cd ~ && zsh -l -i -c codex'
```

At start, Codex shows its hook review. Choose **trust all** (`t`), then exit
Codex. Check: `ssh {HOST} 'grep -c trusted_hash ~/.codex/config.toml'` counts
at least 3.

## 6. Log in the agents

Each login prints a link or code; open it in the browser on GEEKOM.

| Agent | Command |
|---|---|
| Codex | `ssh -t {HOST} 'zsh -l -i -c "codex login --device-auth"'` |
| Grok | `ssh -t {HOST} 'zsh -l -i -c "grok login --device-auth"'` |
| Claude, Linux | `ssh -t {HOST} 'zsh -l -i -c "claude auth login"'` |
| Claude, macOS | `ssh -t {HOST} 'security unlock-keychain ~/Library/Keychains/login.keychain-db && zsh -l -i -c "claude auth login"'` |

**macOS:** unlock the Keychain as shown. Otherwise Claude saves the login to a
file, while T3's service reads an older login from the Keychain and fails with
"Claude could not authenticate".

## 7. Turn on Grok and Antigravity in T3 Code

T3 keeps its provider list in `~/.t3/userdata/settings.json`. There is no `t3`
command for it. Add the same entries GEEKOM has, then restart the T3 service:

```sh
ssh {HOST} 'python3 -I -' <<'EOF'
import json, os
p = os.path.expanduser("~/.t3/userdata/settings.json")
d = json.load(open(p))
pi = d.setdefault("providerInstances", {})
pi.setdefault("grok", {"driver": "grok", "displayName": "Grok"})["enabled"] = True
pi.setdefault("antigravity", {"driver": "antigravity", "displayName": "Antigravity", "accentColor": "#104fda"})["enabled"] = True
tmp = p + ".tmp"; json.dump(d, open(tmp, "w"), indent=2); os.replace(tmp, p)
print(json.dumps(pi))
EOF
ssh {HOST} 'T3=$(ls -d ~/.t3/runtime/versions/*/t3 | sort -V | tail -1); "$T3" service restart'
```

Use the newest `t3` under `~/.t3/runtime/versions/`; an older `~/.local/bin/t3`
link can point to an old version. Claude-API is deliberately left out on Omen
and Mini.

## 8. Antigravity runtime and sign-in for T3

T3 runs Google's `agy-acp-server` **1.4.5** and pins its SHA-256 in T3's code.
On a machine without the T3 window, install it in T3's layout:

```sh
ssh {HOST} 'bash -s' <<'EOF'
set -eu
case "$(uname -s)-$(uname -m)" in
  Linux-x86_64) PA=linux-x64; URL=https://dl.google.com/agy-extensions/releases/linux/agy-acp-server-1.4.5-linux-x86_64.zip; SHA=923923a0d7dc8073f66cc6f78647a3107e3a7ee2b7e1a24df8b3927b5188013b;;
  Darwin-arm64) PA=darwin-arm64; URL=https://dl.google.com/agy-extensions/releases/macos/agy-acp-server-1.4.5-darwin-arm64.zip; SHA=886fff7767d08994ca39eb02c3d01a7532c7325a94aa33aaf52d52068733284f;;
  *) echo "Not covered here; use T3 -> Settings -> Providers -> Install Antigravity"; exit 1;;
esac
M=~/.t3/tools/antigravity-acp/$PA; D=$M/versions/$SHA; S=$(mktemp -d)
curl -fsSL -o "$S/agy.zip" "$URL"
[ "$( (sha256sum "$S/agy.zip" 2>/dev/null || shasum -a 256 "$S/agy.zip") | cut -d' ' -f1)" = "$SHA" ] || { echo "SHA-256 mismatch"; exit 2; }
python3 -I -m zipfile -e "$S/agy.zip" "$S/x"
mkdir -p "$D"; mv "$S/x/agy_acp_server.par" "$S/x/localharness_external" "$D/"; chmod 755 "$D"/*
EB=$(wc -c < "$D/agy_acp_server.par" | tr -d ' '); HB=$(wc -c < "$D/localharness_external" | tr -d ' ')
umask 077
printf '{"releaseId":"%s","version":"1.4.5","executable":{"name":"agy_acp_server.par","bytes":%s},"harness":{"name":"localharness_external","bytes":%s}}' "$SHA" "$EB" "$HB" > "$D/.install-complete.json"
printf '{"releaseId":"%s"}' "$SHA" > "$M/active.json"; rm -rf "$S"; ls -la "$D"
EOF
```

Then copy GEEKOM's T3 Antigravity sign-in (Peter's choice, 2026-11-03). All
machines then share one Google sign-in:

```sh
K=ac0a3dfd6dddb20962cecff6ee5fe65e19d3923be20e52c5ab52ff877f7e4c32
ssh {HOST} "mkdir -p ~/.t3/userdata/providers/antigravity/$K/antigravity-acp && chmod -R go-rwx ~/.t3/userdata/providers/antigravity"
scp -p ~/.t3/userdata/providers/antigravity/$K/antigravity-acp/{acp_token.json,settings.json} {HOST}:.t3/userdata/providers/antigravity/$K/antigravity-acp/
ssh {HOST} "chmod 600 ~/.t3/userdata/providers/antigravity/$K/antigravity-acp/acp_token.json"
```

`ac0a3dfd…` is T3's folder name for the provider instance `antigravity`; it is
the same on every machine.

**Antigravity in T3 works, but without memory.** T3 hides `~/.gemini` hooks
from its Antigravity agent; a fix is requested from T3. Do not add local links.
See [personal Hindsight memory](hindsight-memory.md#limits).

## 9. Check that it works

In T3 Code, start a **new** thread on `{HOST}` for each agent and ask a harmless
question. Then check that machine's Hindsight log:

```sh
ssh {HOST} 'tail -n 20 ~/.hindsight/coding-agents-logs/diag.jsonl | grep -E "retain_ok|inject_recall"'
```

Expect `inject_recall` and `retain_ok` lines for `claude-code`, `codex` and
`grok-build`. T3's provider list can show an old "not logged in" status for a
while; a real thread is the reliable check.

## Undo

1. Remove the Claude `SessionEnd` entry added in step 4.
2. Run the official removal for each agent, for example:
   `ssh {HOST} 'zsh -l -i -c "mise exec node@lts -- npx -y @vectorize-io/hindsight-coding-agents@0.8.1 uninstall claude-code codex pi grok-build opencode antigravity-cli"'`
3. Restore T3's `settings.json` from the backup in step 1 and restart T3.

Removal does not delete memories in the bank.
