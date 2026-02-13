#!/usr/bin/env bash
# =============================================================================
# Layer 5 Manual Curl Entry (placeholder)
# =============================================================================
# This script is intentionally a no-op.
#
# CLI ownership policy:
# - AI CLIs are installed via mise (single-source ownership).
# - Exceptional curl fallbacks are handled by install.sh layer routing.
#
# Current exceptional fallback:
# - sheldon-linux (Linux only), handled by scripts/install/layer_curl.sh
# =============================================================================

set -euo pipefail

echo ""
echo "=============================================="
echo "  Curl Installer Placeholder"
echo "=============================================="
echo ""
echo "No manual curl installers are active in this script."
echo "Use ./install.sh --profile=<profile> for managed installs."
echo ""
