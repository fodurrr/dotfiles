# =============================================================================
# Parse Arguments
# =============================================================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
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
            --yes|-y)
                INTERACTIVE=false
                shift
                ;;
            --extras)
                EXTRAS_MODE=true
                shift
                ;;
            --list-profiles)
                # Check if yq is available (installed during bootstrap)
                if command -v yq &> /dev/null && [[ -f "$APPS_CONFIG" ]]; then
                    echo "Available profiles:"
                    echo ""
                    # Extract unique profiles from apps.toml
                    grep -oE 'profiles = \[.*\]' "$APPS_CONFIG" | grep -oE '"[^"]+"' | tr -d '"' | sort -u | while read -r profile; do
                        # Count apps in this profile
                        count=$(grep -c "\"$profile\"" "$APPS_CONFIG" 2>/dev/null || echo "0")
                        printf "  %-12s (%d apps)\n" "$profile" "$count"
                    done
                else
                    echo "Run bootstrap first (./install.sh), then use --list-profiles"
                    echo "Or check apps.toml for available profiles"
                fi
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done
}
