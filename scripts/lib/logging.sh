# =============================================================================
# Logging Functions (colored output)
# =============================================================================
# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "   ${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "   ${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "   ${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "   ${RED}✗${NC} $1"
}
