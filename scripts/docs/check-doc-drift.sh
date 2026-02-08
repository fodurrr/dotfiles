#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR" || exit 1

FAILED=0

pass() {
  printf '[PASS] %s\n' "$1"
}

fail() {
  printf '[FAIL] %s\n' "$1"
  FAILED=1
}

check_claude_agents_mirror() {
  local diff_output
  diff_output="$(diff -u CLAUDE.md AGENTS.md 2>/dev/null)"
  if [[ -z "$diff_output" ]]; then
    pass 'CLAUDE.md and AGENTS.md are mirrored'
  else
    fail 'CLAUDE.md and AGENTS.md are not mirrored'
    printf '%s\n' "$diff_output" | sed -n '1,120p'
  fi
}

check_local_markdown_links() {
  local file link raw_target target_path
  local links
  local files

  files="README.md CLAUDE.md AGENTS.md docs/*.md"

  for file in $files; do
    [[ -f "$file" ]] || continue

    links="$(grep -oE '\[[^]]+\]\([^)]+\)' "$file" | sed -E 's/.*\(([^)]+)\)/\1/' || true)"

    while IFS= read -r link; do
      [[ -n "$link" ]] || continue

      case "$link" in
        http://*|https://*|mailto:*|\#*)
          continue
          ;;
      esac

      raw_target="${link%%#*}"
      raw_target="${raw_target%%\?*}"
      [[ -n "$raw_target" ]] || continue

      case "$raw_target" in
        /*)
          target_path="$raw_target"
          ;;
        *)
          target_path="$(cd "$(dirname "$file")" && pwd)/$raw_target"
          ;;
      esac

      if [[ ! -e "$target_path" ]]; then
        fail "Broken local link in $file -> $link"
      fi
    done <<< "$links"
  done

  if [[ "$FAILED" -eq 0 ]]; then
    pass 'Local markdown links resolve'
  fi
}

check_stale_tokens() {
  local files token
  files="CLAUDE.md AGENTS.md docs/profile-system.md docs/terminal-workflow-recommendations.md"

  # Update this list intentionally when reintroducing these items in canonical docs.
  for token in 'OneDrive' 'Microsoft Teams' 'direnv' 'chafa'; do
    if rg -n -F "$token" $files >/tmp/doc_drift_token_hits.txt 2>/dev/null; then
      fail "Stale token '$token' found in canonical docs"
      sed -n '1,80p' /tmp/doc_drift_token_hits.txt
    fi
  done

  if [[ "$FAILED" -eq 0 ]]; then
    pass 'No stale canonical-doc tokens found'
  fi
}

check_install_command_smoke() {
  if ./install.sh --help >/dev/null 2>&1; then
    pass './install.sh --help works'
  else
    fail './install.sh --help failed'
  fi

  if ./install.sh --list-profiles >/dev/null 2>&1; then
    pass './install.sh --list-profiles works'
  else
    fail './install.sh --list-profiles failed'
  fi

  if ./install.sh --list-installed >/dev/null 2>&1; then
    pass './install.sh --list-installed works'
  else
    fail './install.sh --list-installed failed'
  fi
}

check_claude_agents_mirror
check_local_markdown_links
check_stale_tokens
check_install_command_smoke

if [[ "$FAILED" -ne 0 ]]; then
  printf '\nDocumentation drift check failed.\n'
  exit 1
fi

printf '\nDocumentation drift check passed.\n'
