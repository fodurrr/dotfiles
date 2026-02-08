# =============================================================================
# Help Output
# =============================================================================

show_help_and_exit() {
    cat << 'EOF'
Dotfiles Installer

Usage:
  ./install.sh [options]

Options:
  --help, -h              Show this help message and exit.
  --profile=<name>        Install apps for one specific profile.
  -p <name>               Add a profile and allow using multiple profiles.
  --clean                 Remove managed apps that are not in the selected profiles.
  --yes, -y               Run non-interactively with no menu prompts.
  --extras                Open extras mode to install individual apps interactively.
  --list-profiles         Print all available profiles from apps.toml.
  --list-installed        Print installed apps from apps.toml with local detection.

Examples:
  ./install.sh
  ./install.sh --profile=hacker
  ./install.sh -p minimal -p standard
  ./install.sh --profile=hacker --clean
  ./install.sh --extras
  ./install.sh --list-profiles
EOF
    exit 0
}
