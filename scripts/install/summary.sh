# =============================================================================
# Installation Summary (Table Display)
# =============================================================================

show_summary_and_reload() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Installation Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    if [[ "$A_LA_CARTE_MODE" == true ]]; then
        echo "  Profiles: a-la-carte"
    else
        echo "  Profiles: ${SELECTED_PROFILES[*]}"
    fi
    echo ""

    if [[ -n "$SUMMARY_INSTALLED" ]]; then
        echo -e "  ${GREEN}Newly Installed${NC}"
        echo ""
        print_summary_table "$SUMMARY_INSTALLED" "✓" "New"
    fi

    if [[ -n "$SUMMARY_SKIPPED" ]]; then
        echo -e "  ${BLUE}Already Installed${NC}"
        echo ""
        print_summary_table "$SUMMARY_SKIPPED" "ℹ" "Skipped"
    fi

    if [[ -n "$SUMMARY_REMOVED" ]]; then
        echo -e "  ${YELLOW}Removed${NC}"
        echo ""
        print_summary_table "$SUMMARY_REMOVED" "⚠" "Removed"
    fi

    if [[ -z "$SUMMARY_INSTALLED" && -z "$SUMMARY_SKIPPED" && -z "$SUMMARY_REMOVED" ]]; then
        echo "  No changes made"
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Press [ENTER] to reload the shell..."
    read
    exec zsh -l
}
