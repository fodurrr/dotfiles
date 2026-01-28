#!/usr/bin/env bash
# =============================================================================
# Layer 5: Curl-Installed Tools (Bleeding Edge / Auto-Updating)
# =============================================================================
# These AI coding tools have official curl installers that provide:
# - Auto-updates to latest versions
# - Vendor-recommended installation method
# - Features days/weeks before Homebrew or Mise packages
#
# When to add a tool here:
# - It's an AI coding tool that evolves rapidly
# - It has an official curl/shell installer
# - Freshness matters more than version pinning
#
# Tools without curl installers should use Mise (Layer 3) instead.
# =============================================================================
#
# SECURITY NOTE:
# This script uses `curl | bash` which executes remote code. This is an
# intentional trade-off for AI coding tools where:
#   1. The vendor (Anthropic, Anomaly) provides this as the official method
#   2. Auto-updates require this installation approach
#   3. We trust these specific vendors and their HTTPS endpoints
#
# If you're uncomfortable with this, install these tools manually or via
# alternative package managers when available.
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# =============================================================================
# Claude Code (Anthropic)
# =============================================================================
# Official installer: https://claude.ai/install.sh
# - Auto-updates enabled
# - Recommended by Anthropic for latest features
# =============================================================================
install_claude_code() {
    log_info "Installing Claude Code CLI..."

    if command -v claude &>/dev/null; then
        local current_version
        current_version=$(claude --version 2>/dev/null || echo "unknown")
        log_info "  Current version: $current_version"
    else
        log_info "  Not currently installed"
    fi

    # SECURITY: Intentional curl|bash - see header comment for rationale
    log_info "  Running official installer..."
    curl -fsSL https://claude.ai/install.sh | bash

    # Copy to Homebrew bin for sandvault access (sandvault can't follow symlinks into ~/)
    if [[ -e "$HOME/.local/bin/claude" ]]; then
        local real_claude
        real_claude=$(readlink -f "$HOME/.local/bin/claude" 2>/dev/null || echo "$HOME/.local/bin/claude")
        if [[ -f "$real_claude" ]]; then
            log_info "  Copying to /opt/homebrew/bin/ for sandvault compatibility..."
            cp "$real_claude" /opt/homebrew/bin/claude
            chmod +x /opt/homebrew/bin/claude
            log_info "  Copied: $real_claude → /opt/homebrew/bin/claude"
        fi
    fi

    if command -v claude &>/dev/null; then
        local new_version
        new_version=$(claude --version 2>/dev/null || echo "unknown")
        log_info "  Installed version: $new_version"
        return 0
    else
        log_error "  Installation may have failed - 'claude' not found in PATH"
        return 1
    fi
}

# =============================================================================
# OpenCode (Anomaly)
# =============================================================================
# Official installer: https://opencode.ai/install
# - Auto-updates enabled
# - Open source AI coding agent
# =============================================================================
install_opencode() {
    log_info "Installing OpenCode CLI..."

    if command -v opencode &>/dev/null; then
        local current_version
        current_version=$(opencode --version 2>/dev/null || echo "unknown")
        log_info "  Current version: $current_version"
    else
        log_info "  Not currently installed"
    fi

    # SECURITY: Intentional curl|bash - see header comment for rationale
    log_info "  Running official installer..."
    curl -fsSL https://opencode.ai/install | bash

    if command -v opencode &>/dev/null; then
        local new_version
        new_version=$(opencode --version 2>/dev/null || echo "unknown")
        log_info "  Installed version: $new_version"
        return 0
    else
        log_error "  Installation may have failed - 'opencode' not found in PATH"
        return 1
    fi
}

# =============================================================================
# Main
# =============================================================================
main() {
    echo ""
    echo "=============================================="
    echo "  Layer 5: AI Coding Tools (curl installers)"
    echo "=============================================="
    echo ""

    local failures=0

    install_claude_code || ((failures++))
    echo ""
    install_opencode || ((failures++))

    echo ""
    echo "=============================================="
    if [[ $failures -eq 0 ]]; then
        echo "  Layer 5 Complete"
    else
        echo "  Layer 5 Complete (with $failures failure(s))"
    fi
    echo "=============================================="
    echo ""

    return $failures
}

main "$@"
