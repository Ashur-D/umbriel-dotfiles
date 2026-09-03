#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/colors.sh"

header "Step 1: AUR Helper (yay)"

if command -v yay &>/dev/null; then
    success "yay is already installed ($(yay --version | head -n1))."
    exit 0
fi

info "Installing base build dependencies (git, base-devel)..."
sudo pacman -S --needed --noconfirm git base-devel

BUILD_DIR=$(mktemp -d)
trap 'rm -rf "$BUILD_DIR"' EXIT

info "Cloning and building yay in $BUILD_DIR..."
git clone https://aur.archlinux.org/yay.git "$BUILD_DIR/yay"
(
    cd "$BUILD_DIR/yay"
    makepkg -si --noconfirm
)

success "yay installed successfully!"
