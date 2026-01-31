#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Running validation checks..."

echo "Checking install.sh syntax..."
bash -n "$ROOT_DIR/install.sh"

if command -v yq >/dev/null 2>&1; then
  echo "Validating apps.toml syntax..."
  yq -p toml -oy '.' "$ROOT_DIR/apps.toml" >/dev/null
else
  echo "Skipping apps.toml validation (yq not found)."
fi

echo "Validation complete."
