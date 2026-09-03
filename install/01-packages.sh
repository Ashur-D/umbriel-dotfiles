#!/bin/bash
set -euo pipefail

echo ":: [1/3] Installing yay and package stack..."

# Ensure Yay is installed
if ! command -v yay &>/dev/null; then
    echo ":: Installing yay from AUR..."
    sudo pacman -S --needed --noconfirm git base-devel
    BUILD_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$BUILD_DIR/yay"
    (cd "$BUILD_DIR/yay" && makepkg -si --noconfirm)
    rm -rf "$BUILD_DIR"
fi

# All desktop, shell, theming, and tool packages
PACKAGES=(
    # Compositor & Desktop Shell
    xdg-desktop-portal-umbriel-git
    umbriel-git
    noctalia-git

    # Terminal, Shell & Tools
    kitty starship fastfetch yazi neovim chezmoi xdg-user-dirs

    # Audio & Power
    pipewire pipewire-pulse wireplumber playerctl power-profiles-daemon

    # Networking & Bluetooth
    bluez iwd

    # Capture, Fonts & GTK
    wl-clipboard satty gpu-screen-recorder bibata-cursor-theme-bin maplemono-ttf adw-gtk-theme
)

echo ":: Installing all packages..."
yay -S --needed --noconfirm --mflags --nocheck "${PACKAGES[@]}"
echo ":: Packages installed successfully."
