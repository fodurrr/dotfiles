#!/usr/bin/env bash
#
# common.sh - Shared utilities for dotfiles installation
#
# This library provides common functions used across all installation scripts:
# - Color output and logging
# - OS detection
# - Error handling
# - Utility functions

set -euo pipefail

# Source guard - prevent multiple sourcing
if [[ -n "${COMMON_SH_LOADED:-}" ]]; then
    return 0
fi
readonly COMMON_SH_LOADED=1

# Color codes for output
readonly COLOR_RESET='\033[0m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_MAGENTA='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_BOLD='\033[1m'

# Icons for better UX
readonly ICON_SUCCESS="✓"
readonly ICON_ERROR="✗"
readonly ICON_INFO="ℹ"
readonly ICON_WARNING="⚠"
readonly ICON_ARROW="→"

# Logging functions
log_info() {
    echo -e "${COLOR_BLUE}${ICON_INFO}${COLOR_RESET} $*"
}

log_success() {
    echo -e "${COLOR_GREEN}${ICON_SUCCESS}${COLOR_RESET} $*"
}

log_warning() {
    echo -e "${COLOR_YELLOW}${ICON_WARNING}${COLOR_RESET} $*"
}

log_error() {
    echo -e "${COLOR_RED}${ICON_ERROR}${COLOR_RESET} $*" >&2
}

log_step() {
    echo -e "${COLOR_CYAN}${ICON_ARROW}${COLOR_RESET} ${COLOR_BOLD}$*${COLOR_RESET}"
}

# Die function for fatal errors
die() {
    log_error "$@"
    exit 1
}

# Detect operating system
detect_os() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        echo "${ID,,}"  # Convert to lowercase
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Detect OS version
detect_os_version() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        echo "${VERSION_ID:-unknown}"
    else
        echo "unknown"
    fi
}

# Check if running on supported OS
is_supported_os() {
    local os
    os=$(detect_os)
    case "$os" in
        ubuntu|debian|fedora)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Get supported OS list
get_supported_os_list() {
    echo "Ubuntu, Debian, Fedora"
}

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Check if running as root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Ensure running as normal user (not root)
ensure_not_root() {
    if is_root; then
        die "This script should not be run as root. Please run as a normal user."
    fi
}

# Ensure sudo is available
ensure_sudo() {
    if ! command_exists sudo; then
        die "sudo is required but not installed. Please install sudo first."
    fi

    # Test sudo access
    if ! sudo -n true 2>/dev/null; then
        log_info "This script requires sudo access. You may be prompted for your password."
        sudo -v || die "Failed to obtain sudo access"
    fi

    # Keep sudo alive in background
    while true; do
        sudo -n true
        sleep 50
        kill -0 "$$" 2>/dev/null || exit
    done &
}

# Check internet connectivity
check_internet() {
    if ! ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
        return 1
    fi
    return 0
}

# Ensure internet connectivity
ensure_internet() {
    log_step "Checking internet connectivity..."
    if ! check_internet; then
        die "No internet connection detected. Please check your network connection."
    fi
    log_success "Internet connection OK"
}

# Check available disk space (in MB)
get_available_space_mb() {
    local path="${1:-.}"
    df -m "$path" | awk 'NR==2 {print $4}'
}

# Ensure minimum disk space
ensure_disk_space() {
    local required_mb="$1"
    local path="${2:-.}"

    local available_mb
    available_mb=$(get_available_space_mb "$path")

    if ((available_mb < required_mb)); then
        die "Insufficient disk space. Required: ${required_mb}MB, Available: ${available_mb}MB"
    fi
}

# Backup file if it exists
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backing up $file to $backup"
        cp "$file" "$backup"
    fi
}

# Backup directory if it exists
backup_directory() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        local backup="${dir}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backing up $dir to $backup"
        cp -r "$dir" "$backup"
    fi
}

# Ask yes/no question (returns 0 for yes, 1 for no)
ask_yes_no() {
    local question="$1"
    local default="${2:-y}"  # Default to yes

    if [[ "$default" == "y" ]]; then
        local prompt="[Y/n]"
        local default_answer="y"
    else
        local prompt="[y/N]"
        local default_answer="n"
    fi

    while true; do
        read -rp "$question $prompt " answer
        answer="${answer:-$default_answer}"
        case "${answer,,}" in
            y|yes)
                return 0
                ;;
            n|no)
                return 1
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
}

# Check if running in CI/non-interactive environment
is_ci() {
    [[ -n "${CI:-}" ]] || [[ -n "${GITHUB_ACTIONS:-}" ]] || [[ ! -t 0 ]]
}

# Get script directory (where the script is located)
get_script_dir() {
    local source="${BASH_SOURCE[0]}"
    while [[ -L "$source" ]]; do
        local dir
        dir="$(cd -P "$(dirname "$source")" && pwd)"
        source="$(readlink "$source")"
        [[ $source != /* ]] && source="$dir/$source"
    done
    cd -P "$(dirname "$source")" && pwd
}

# Get dotfiles root directory
get_dotfiles_root() {
    local script_dir
    script_dir=$(get_script_dir)
    # Assuming scripts are in scripts/lib/, go up two levels
    cd "$script_dir/../.." && pwd
}

# Print a separator line
print_separator() {
    local char="${1:-─}"
    local width="${2:-60}"
    printf "%${width}s\n" | tr ' ' "$char"
}

# Print a section header
print_header() {
    local title="$1"
    echo
    print_separator "═"
    echo -e "${COLOR_BOLD}${COLOR_CYAN}${title}${COLOR_RESET}"
    print_separator "═"
    echo
}

# Download file with curl or wget
download_file() {
    local url="$1"
    local output="$2"

    if command_exists curl; then
        curl -fsSL "$url" -o "$output"
    elif command_exists wget; then
        wget -q "$url" -O "$output"
    else
        die "Neither curl nor wget is installed. Cannot download files."
    fi
}

# Extract version from string (e.g., "v1.2.3" -> "1.2.3")
extract_version() {
    local version="$1"
    echo "$version" | sed 's/^v//'
}

# Compare versions (returns 0 if v1 >= v2)
version_ge() {
    local v1="$1"
    local v2="$2"

    # Extract numeric version
    v1=$(extract_version "$v1")
    v2=$(extract_version "$v2")

    # Use sort -V for version comparison
    if printf '%s\n%s\n' "$v2" "$v1" | sort -V -C; then
        return 0
    else
        return 1
    fi
}

# Export functions for use in other scripts
export -f log_info log_success log_warning log_error log_step
export -f die command_exists is_root ensure_not_root ensure_sudo
export -f detect_os detect_os_version is_supported_os get_supported_os_list
export -f check_internet ensure_internet
export -f get_available_space_mb ensure_disk_space
export -f backup_file backup_directory ask_yes_no is_ci
export -f get_script_dir get_dotfiles_root
export -f print_separator print_header
export -f download_file extract_version version_ge
