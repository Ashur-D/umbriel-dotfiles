#!/bin/bash
set -euo pipefail

echo ":: [1/3] Installing yay and core package stack..."

# Ensure Yay is installed
if ! command -v yay &>/dev/null; then
    echo ":: Installing yay from AUR..."
    sudo pacman -S --needed --noconfirm git base-devel
    BUILD_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$BUILD_DIR/yay"
    (cd "$BUILD_DIR/yay" && makepkg -si --noconfirm)
    rm -rf "$BUILD_DIR"
fi

# Core desktop, shell, theming, and tool packages
CORE_PACKAGES=(
    # Compositor & Desktop Shell
    xdg-desktop-portal-umbriel-git
    umbriel-git
    noctalia-git

    # Terminal, Shell & Tools
    kitty
    starship
    fastfetch
    yazi
    neovim
    chezmoi
    xdg-user-dirs

    # Audio & Power
    pipewire
    pipewire-pulse
    wireplumber
    playerctl
    power-profiles-daemon
    python-gobject

    # Networking & Bluetooth
    bluez
    iwd

    # Capture, Fonts & GTK
    wl-clipboard
    satty
    gpu-screen-recorder
    bibata-cursor-theme-bin
    maplemono-ttf
    adw-gtk-theme
)

echo ":: Installing core packages..."
yay -S --needed --noconfirm --mflags --nocheck "${CORE_PACKAGES[@]}"
echo ":: Core packages installed successfully."
