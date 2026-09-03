#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/colors.sh"

header "Step 3: Graphics Drivers"

# Auto-detect Nvidia GPU
HAS_NVIDIA=false
if lspci -k 2>/dev/null | grep -Ei "vga|3d" | grep -qi "nvidia"; then
    HAS_NVIDIA=true
fi

if [ "$HAS_NVIDIA" = true ]; then
    info "Nvidia GPU detected via lspci."
    echo -ne "${CYAN}Install Nvidia proprietary drivers and Wayland integration? [Y/n]: ${RESET}"
    read -r nvidia_choice
    nvidia_choice="${nvidia_choice:-y}"
else
    echo -ne "${CYAN}No Nvidia GPU auto-detected. Install Nvidia drivers anyway? [y/N]: ${RESET}"
    read -r nvidia_choice
    nvidia_choice="${nvidia_choice:-n}"
fi

if [[ "$nvidia_choice" =~ ^[Yy]$ ]]; then
    nvidia_pkgs=(
        nvidia-dkms
        nvidia-utils
        lib32-nvidia-utils
        egl-wayland
        libva-nvidia-driver
    )

    info "Detecting installed kernels to install matching headers..."
    for k in linux linux-zen linux-lts linux-cachyos linux-hardened; do
        if pacman -Qs "^${k}$" > /dev/null 2>&1; then
            info "  - Found kernel: $k -> adding ${k}-headers"
            nvidia_pkgs+=("${k}-headers")
        fi
    done

    info "Installing Nvidia packages: ${nvidia_pkgs[*]}"
    yay -S --needed --noconfirm "${nvidia_pkgs[@]}"
    success "Nvidia drivers and matching kernel headers installed!"
else
    info "Skipping Nvidia driver installation."
fi
