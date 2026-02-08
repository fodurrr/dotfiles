# =============================================================================
# Parse Arguments
# =============================================================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help_and_exit
                ;;
            --profile=*)
                local profile_value
                profile_value="${1#*=}"
                SELECTED_PROFILES+=("$profile_value")
                INTERACTIVE=false
                shift
                ;;
            -p)
                SELECTED_PROFILES+=("$2")
                INTERACTIVE=false
                shift 2
                ;;
            --clean)
                CLEAN_MODE=true
                shift
                ;;
            --clean-untracked)
                CLEAN_UNTRACKED=true
                shift
                ;;
            --yes|-y)
                YES_MODE=true
                INTERACTIVE=false
                shift
                ;;
            --extras)
                EXTRAS_MODE=true
                shift
                ;;
            --reconcile-casks)
                RECONCILE_CASKS=true
                shift
                ;;
            --reconcile-dry-run)
                RECONCILE_CASKS=true
                RECONCILE_DRY_RUN=true
                shift
                ;;
            --reconcile-only)
                RECONCILE_CASKS=true
                RECONCILE_ONLY=true
                shift
                ;;
            --list-profiles)
                if command -v yq >/dev/null 2>&1 && [[ -f "$APPS_CONFIG" ]]; then
                    echo "Available profiles:"
                    echo ""
                    grep -oE 'profiles = \[.*\]' "$APPS_CONFIG" | grep -oE '"[^"]+"' | tr -d '"' | sort -u | while read -r profile; do
                        count=$(grep -c "\"$profile\"" "$APPS_CONFIG" 2>/dev/null || echo "0")
                        printf "  %-12s (%d apps)\n" "$profile" "$count"
                    done
                else
                    echo "Run bootstrap first (./install.sh), then use --list-profiles"
                    echo "Or check apps.toml for available profiles"
                fi
                exit 0
                ;;
            --list-installed)
                list_installed_and_exit
                ;;
            *)
                echo "Unknown option: $1"
                echo "Run ./install.sh --help to see available options."
                exit 1
                ;;
        esac
    done
}
