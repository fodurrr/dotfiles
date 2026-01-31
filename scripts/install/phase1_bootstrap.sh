#!/bin/bash

# =============================================================================
# PHASE 1: BOOTSTRAP (runs first, unconditionally)
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Phase 1: Bootstrap"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Install Homebrew if missing
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    echo -e "\033[33m   Be patient. Initial installation can take several minutes.\033[0m"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Setup Homebrew environment
if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
else
    echo "Error: Homebrew not found after installation"
    exit 1
fi

# Install infrastructure packages
echo "Installing infrastructure packages..."
echo -e "\033[33m   Be patient. Initial installation can take several minutes.\033[0m"
if ! brew bundle --file="$DOTFILES_DIR/Brewfile.bootstrap"; then
    echo "Error: brew bundle failed"
    exit 1
fi

# Install TPM (Tmux Plugin Manager) if not present
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    log_info "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    log_success "TPM installed. After tmux starts, press Ctrl+A then Shift+I to install plugins."
else
    log_info "TPM already installed"
fi
