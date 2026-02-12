# =============================================================================
# Summary Helpers
# =============================================================================

# Add entry to summary list (newline+pipe delimited format)
add_to_summary() {
    local list_type="$1"
    local name="$2"
    local app_key="$3"

    local desc
    desc=$(get_app_prop "$app_key" "description")
    [[ -z "$desc" ]] && desc="-"

    local record="${name}|${desc}"

    case "$list_type" in
        INSTALLED)
            [[ -z "$SUMMARY_INSTALLED" ]] && SUMMARY_INSTALLED="$record" || SUMMARY_INSTALLED="${SUMMARY_INSTALLED}
${record}"
            ;;
        SKIPPED)
            [[ -z "$SUMMARY_SKIPPED" ]] && SUMMARY_SKIPPED="$record" || SUMMARY_SKIPPED="${SUMMARY_SKIPPED}
${record}"
            ;;
        REMOVED)
            [[ -z "$SUMMARY_REMOVED" ]] && SUMMARY_REMOVED="$record" || SUMMARY_REMOVED="${SUMMARY_REMOVED}
${record}"
            ;;
    esac
}

# Print summary table using gum
print_summary_table() {
    local data="$1"
    local status_symbol="$2"
    local status_text="$3"

    [[ -z "$data" ]] && return

    local csv_data=""
    local name desc
    while IFS='|' read -r name desc; do
        [[ -z "$name" ]] && continue
        # Escape commas in description for CSV
        desc="${desc//,/;}"
        [[ -z "$csv_data" ]] && csv_data="${name},${status_symbol} ${status_text},${desc}" || csv_data="${csv_data}
${name},${status_symbol} ${status_text},${desc}"
    done <<< "$data"

    if command -v gum >/dev/null 2>&1; then
        echo "$csv_data" | gum table \
            --separator="," \
            --columns="Package,Status,Description" \
            --widths="22,12,40" \
            --print \
            --border="rounded"
    else
        printf "  %-22s %-12s %s\n" "Package" "Status" "Description"
        printf "  %-22s %-12s %s\n" "----------------------" "------------" "------------------------------"
        while IFS='|' read -r name desc; do
            [[ -z "$name" ]] && continue
            printf "  %-22s %-12s %s\n" "$name" "${status_symbol} ${status_text}" "$desc"
        done <<< "$data"
    fi
    echo ""
}
