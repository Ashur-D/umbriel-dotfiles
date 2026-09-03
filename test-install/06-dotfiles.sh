#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
source "$SCRIPT_DIR/colors.sh"

header "Step 6: Apply Dotfiles (Chezmoi)"

if ! command -v chezmoi &>/dev/null; then
    error "chezmoi is not installed. Run step 4 or install chezmoi."
    exit 1
fi

info "Configuring chezmoi source directory to $REPO_DIR..."
mkdir -p "$HOME/.config/chezmoi"
cat << CHEZMOI_CONF > "$HOME/.config/chezmoi/chezmoi.toml"
sourceDir = "$REPO_DIR"
CHEZMOI_CONF

info "Applying dotfiles to home directory..."
chezmoi apply --force

success "All dotfiles applied successfully with Chezmoi!"
