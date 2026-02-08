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
  --clean-untracked       Allow non-interactive clean mode to remove untracked Homebrew apps.
  --yes, -y               Run non-interactively with no menu prompts.
  --extras                Open extras mode to install individual apps interactively.
  --reconcile-casks       Reconcile unmanaged /Applications GUI apps into Homebrew cask ownership.
  --reconcile-dry-run     Preview reconciliation actions without changing anything.
  --reconcile-only        Run reconciliation and exit without running install layers.
  --list-profiles         Print all available profiles from apps.toml.
  --list-installed        Print installed apps from apps.toml with local detection.

Examples:
  ./install.sh
  ./install.sh --profile=hacker
  ./install.sh -p minimal -p standard
  ./install.sh --profile=hacker --clean
  ./install.sh --profile=hacker --clean --clean-untracked --yes
  ./install.sh --extras
  ./install.sh --profile=standard --reconcile-casks
  ./install.sh --profile=standard --reconcile-casks --reconcile-dry-run
  ./install.sh --list-profiles
EOF
    exit 0
}
