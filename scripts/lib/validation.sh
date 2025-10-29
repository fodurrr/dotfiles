#!/usr/bin/env bash
#
# validation.sh - Validation and idempotency checks
#
# Provides functions to validate installations and ensure idempotency.
# These checks prevent unnecessary reinstallation and verify successful setups.

set -euo pipefail

# Source guard - prevent multiple sourcing
if [[ -n "${VALIDATION_SH_LOADED:-}" ]]; then
    return 0
fi
readonly VALIDATION_SH_LOADED=1

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/common.sh"

# Validate command is installed and optionally check version
validate_command() {
    local cmd="$1"
    local error_msg="${2:-Command '$cmd' not found}"
    local min_version="${3:-}"

    if ! command_exists "$cmd"; then
        die "$error_msg"
    fi

    log_success "$cmd is installed"

    # Check version if specified
    if [[ -n "$min_version" ]]; then
        validate_version "$cmd" "$min_version"
    fi

    return 0
}

# Validate command with version check
validate_version() {
    local cmd="$1"
    local min_version="$2"
    local version_flag="${3:---version}"

    # Get installed version
    local installed_version
    installed_version=$($cmd $version_flag 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1)

    if [[ -z "$installed_version" ]]; then
        log_warning "Could not determine version of $cmd"
        return 0
    fi

    # Compare versions
    if version_ge "$installed_version" "$min_version"; then
        log_success "$cmd version $installed_version >= $min_version"
        return 0
    else
        die "$cmd version $installed_version is less than required $min_version"
    fi
}

# Check if file exists
validate_file() {
    local file="$1"
    local error_msg="${2:-File '$file' not found}"

    if [[ ! -f "$file" ]]; then
        die "$error_msg"
    fi

    log_success "File exists: $file"
    return 0
}

# Check if directory exists
validate_directory() {
    local dir="$1"
    local error_msg="${2:-Directory '$dir' not found}"

    if [[ ! -d "$dir" ]]; then
        die "$error_msg"
    fi

    log_success "Directory exists: $dir"
    return 0
}

# Check if symlink exists and points to target
validate_symlink() {
    local link="$1"
    local target="${2:-}"

    if [[ ! -L "$link" ]]; then
        die "Symlink not found: $link"
    fi

    if [[ -n "$target" ]]; then
        local actual_target
        actual_target=$(readlink -f "$link")
        local expected_target
        expected_target=$(readlink -f "$target")

        if [[ "$actual_target" != "$expected_target" ]]; then
            die "Symlink $link points to $actual_target, expected $expected_target"
        fi
    fi

    log_success "Symlink exists: $link"
    return 0
}

# Check if service is running (systemd)
validate_service() {
    local service="$1"

    if ! systemctl is-active --quiet "$service"; then
        die "Service '$service' is not running"
    fi

    log_success "Service is running: $service"
    return 0
}

# Check if port is listening
validate_port() {
    local port="$1"
    local protocol="${2:-tcp}"

    if ! command_exists ss && ! command_exists netstat; then
        log_warning "Cannot check port $port: neither ss nor netstat is available"
        return 0
    fi

    if command_exists ss; then
        if ! ss -ln "$protocol" | grep -q ":$port "; then
            die "Port $port is not listening"
        fi
    else
        if ! netstat -ln "$protocol" | grep -q ":$port "; then
            die "Port $port is not listening"
        fi
    fi

    log_success "Port $port is listening"
    return 0
}

# Check if URL is reachable
validate_url() {
    local url="$1"
    local expected_code="${2:-200}"

    if ! command_exists curl; then
        log_warning "Cannot validate URL: curl not installed"
        return 0
    fi

    local actual_code
    actual_code=$(curl -o /dev/null -s -w "%{http_code}" "$url")

    if [[ "$actual_code" != "$expected_code" ]]; then
        die "URL $url returned $actual_code, expected $expected_code"
    fi

    log_success "URL is reachable: $url"
    return 0
}

# Check if shell is set correctly
validate_shell() {
    local expected_shell="$1"

    local current_shell
    current_shell=$(basename "$SHELL")

    if [[ "$current_shell" != "$expected_shell" ]]; then
        log_warning "Current shell is $current_shell, expected $expected_shell"
        log_info "You may need to log out and log back in, or run: chsh -s \$(which $expected_shell)"
        return 1
    fi

    log_success "Shell is set to $expected_shell"
    return 0
}

# Check if environment variable is set
validate_env_var() {
    local var_name="$1"
    local expected_value="${2:-}"

    if [[ -z "${!var_name:-}" ]]; then
        die "Environment variable '$var_name' is not set"
    fi

    if [[ -n "$expected_value" && "${!var_name}" != "$expected_value" ]]; then
        die "Environment variable '$var_name' is '${!var_name}', expected '$expected_value'"
    fi

    log_success "Environment variable is set: $var_name"
    return 0
}

# Check if path is in PATH environment variable
validate_path() {
    local path="$1"

    if [[ ":$PATH:" != *":$path:"* ]]; then
        log_warning "Path is not in PATH: $path"
        return 1
    fi

    log_success "Path is in PATH: $path"
    return 0
}

# Check if git repository is initialized
validate_git_repo() {
    local repo_path="${1:-.}"

    if [[ ! -d "$repo_path/.git" ]]; then
        die "Not a git repository: $repo_path"
    fi

    log_success "Git repository: $repo_path"
    return 0
}

# Check if git config is set
validate_git_config() {
    local key="$1"
    local expected_value="${2:-}"

    local actual_value
    actual_value=$(git config --global "$key" 2>/dev/null || echo "")

    if [[ -z "$actual_value" ]]; then
        die "Git config '$key' is not set"
    fi

    if [[ -n "$expected_value" && "$actual_value" != "$expected_value" ]]; then
        die "Git config '$key' is '$actual_value', expected '$expected_value'"
    fi

    log_success "Git config is set: $key=$actual_value"
    return 0
}

# Validate binary has correct permissions
validate_executable() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        die "File not found: $file"
    fi

    if [[ ! -x "$file" ]]; then
        die "File is not executable: $file"
    fi

    log_success "File is executable: $file"
    return 0
}

# Check if component is already installed (generic check)
is_component_installed() {
    local component="$1"

    case "$component" in
        zsh)
            command_exists zsh
            ;;
        starship)
            command_exists starship
            ;;
        zinit)
            [[ -d "${HOME}/.local/share/zinit" ]]
            ;;
        neovim|nvim)
            command_exists nvim
            ;;
        devbox)
            command_exists devbox
            ;;
        lazygit)
            command_exists lazygit
            ;;
        gh)
            command_exists gh
            ;;
        eza)
            command_exists eza
            ;;
        fzf)
            command_exists fzf
            ;;
        bat)
            command_exists bat || command_exists batcat
            ;;
        zoxide)
            command_exists zoxide
            ;;
        fabric)
            command_exists fabric || [[ -f "$HOME/go/bin/fabric" ]]
            ;;
        stow)
            command_exists stow
            ;;
        *)
            command_exists "$component"
            ;;
    esac
}

# Skip component if already installed
skip_if_installed() {
    local component="$1"
    local component_name="${2:-$component}"

    if is_component_installed "$component"; then
        log_success "$component_name is already installed, skipping"
        return 0  # Return success to skip
    fi

    return 1  # Return failure to continue with installation
}

# Validate all core components are installed
validate_core_installation() {
    log_step "Validating core installation..."

    local failed=0

    # Check critical commands
    for cmd in git zsh curl; do
        if ! command_exists "$cmd"; then
            log_error "$cmd is not installed"
            ((failed++))
        fi
    done

    # Check home directory structure
    if [[ ! -d "$HOME/.config" ]]; then
        log_error "~/.config directory does not exist"
        ((failed++))
    fi

    if [[ $failed -eq 0 ]]; then
        log_success "Core installation validated"
        return 0
    else
        die "Core installation validation failed with $failed error(s)"
    fi
}

# Validate profile-specific installation
validate_profile_installation() {
    local profile="$1"

    log_step "Validating $profile profile installation..."

    case "$profile" in
        quick)
            validate_command zsh
            validate_command starship
            validate_directory "$HOME/.local/share/zinit"
            ;;
        full)
            validate_command zsh
            validate_command starship
            validate_command nvim
            validate_command devbox
            validate_command lazygit
            validate_directory "$HOME/.local/share/zinit"
            validate_directory "$HOME/.config/nvim"
            ;;
        *)
            log_warning "Unknown profile: $profile"
            return 1
            ;;
    esac

    log_success "$profile profile installation validated"
    return 0
}

# Export functions for use in other scripts
export -f validate_command validate_version validate_file validate_directory
export -f validate_symlink validate_service validate_port validate_url
export -f validate_shell validate_env_var validate_path
export -f validate_git_repo validate_git_config validate_executable
export -f is_component_installed skip_if_installed
export -f validate_core_installation validate_profile_installation
