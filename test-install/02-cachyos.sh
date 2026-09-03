#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/colors.sh"

header "Step 2: CachyOS Kernel & Repos (Optional)"

# Check if already installed
if pacman -Qs ^cachyos-keyring$ > /dev/null 2>&1; then
    success "CachyOS repositories are already active."
    exit 0
fi

echo -ne "${CYAN}Do you want to install the CachyOS optimized kernel & repositories? [y/N]: ${RESET}"
read -r cachy_choice

if [[ "$cachy_choice" =~ ^[Yy]$ ]]; then
    info "Fetching CachyOS repository installer..."
    TMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TMP_DIR"' EXIT

    curl -sSL https://mirror.cachyos.org/cachyos-repo.tar.xz -o "$TMP_DIR/cachyos-repo.tar.xz"
    tar -xf "$TMP_DIR/cachyos-repo.tar.xz" -C "$TMP_DIR"
    (
        cd "$TMP_DIR/cachyos-repo"
        sudo ./cachyos-repo.sh
    )

    info "Installing linux-cachyos, headers, and kernel manager..."
    yay -S --needed --noconfirm linux-cachyos linux-cachyos-headers cachyos-kernel-manager
    success "CachyOS integration complete. (Update bootloader if needed)"
else
    info "Skipping CachyOS repositories (Standard Arch kernel/repos will be used)."
fi
