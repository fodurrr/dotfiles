#!/bin/bash

# Helper function to check if a command exists
check_and_install() {
    local cmd=$1
    local pkg=${2:-$1}  # If no package name provided, use command name
    local msg=${3:-$pkg} # If no custom message provided, use package name
    
    if ! command -v "$cmd" &> /dev/null; then
        echo "Installing $msg..."
        sudo dnf install -y "$pkg"
    else
        echo "$msg is already installed"
    fi
}

# Helper function to check if a package is installed
check_and_install_pkg() {
    local pkg=$1
    local msg=${2:-$pkg}  # If no custom message provided, use package name
    
    if ! rpm -q "$pkg" &> /dev/null; then
        echo "Installing $msg..."
        sudo dnf install -y "$pkg"
    else
        echo "$msg is already installed"
    fi
}

#################################################
# System Updates and Base Utilities
#################################################
# Update the system packages to their latest versions
sudo dnf update -y

# Install essential system utilities
check_and_install_pkg gpg-utils "GPG utilities"
check_and_install_pkg xdg-utils "XDG utilities"
check_and_install_pkg xclip
check_and_install_pkg xsel

#################################################
# Development Essentials
#################################################
# Check if Development Tools group is installed
if ! dnf group list installed "Development Tools" &> /dev/null; then
    echo "Installing Development Tools group..."
    sudo dnf groupinstall -y "Development Tools"
else
    echo "Development Tools group is already installed"
fi

#################################################
# Git Configuration
#################################################
# Check and install git
check_and_install git

# Set up global Git preferences
git config --global init.defaultBranch main         # Use 'main' as default branch name
git config --global user.email "fodurrr@gmail.com"  # Set Git email
git config --global user.name "Peter Fodor"         # Set Git username

#################################################
# Shell Environment Setup
#################################################
# Check and install Zsh
check_and_install zsh

# Install Starship if not installed
if ! command -v starship &> /dev/null; then
    echo "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh
else
    echo "Starship prompt is already installed"
fi

# Install Zinit if not installed
if [ ! -d "${HOME}/.zinit" ]; then
    echo "Installing Zinit..."
    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
else
    echo "Zinit is already installed"
fi

#################################################
# Development Tools
#################################################
# Check and install Neovim
if ! command -v nvim &> /dev/null; then
    echo "Installing Neovim..."
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf nvim-linux64.tar.gz
    sudo rm -rf nvim-linux64.tar.gz

    # Backup existing Neovim configuration
    mv ~/.config/nvim{,.bak} 2>/dev/null      # Required backup
    mv ~/.local/share/nvim{,.bak} 2>/dev/null # Optional but recommended
    mv ~/.local/state/nvim{,.bak} 2>/dev/null # Optional but recommended
    mv ~/.cache/nvim{,.bak} 2>/dev/null       # Optional but recommended
else
    echo "Neovim is already installed"
fi

# Check and install LazyGit
if ! command -v lazygit &> /dev/null; then
    echo "Installing LazyGit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    sudo rm -rf lazygit.tar.gz
else
    echo "LazyGit is already installed"
fi

# Check and install GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "Installing GitHub CLI..."
    sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo dnf install -y gh
else
    echo "GitHub CLI is already installed"
fi

# Check and install devbox
if ! command -v devbox &> /dev/null; then
    echo "Installing devbox..."
    curl -fsSL https://get.jetify.com/devbox | bash
else
    echo "devbox is already installed"
fi

#################################################
# Modern CLI Tools
#################################################
# Check and install modern CLI tools
check_and_install fzf "Fuzzy finder"
check_and_install bat "Modern cat replacement"

# Check and install eza
if ! command -v eza &> /dev/null; then
    echo "Installing eza..."
    sudo dnf copr enable varlad/eza -y
    sudo dnf install -y eza
else
    echo "eza is already installed"
fi

# Check and install zoxide
if ! command -v zoxide &> /dev/null; then
    echo "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
else
    echo "zoxide is already installed"
fi
