#!/bin/bash
set -euo pipefail

echo ":: [1/3] Installing yay and core package stack..."

# Ensure Yay is installed (build-only with makepkg -s, then install with sudo pacman -U to prevent second password prompt)
if ! command -v yay &>/dev/null; then
    echo ":: Installing yay from AUR..."
    sudo pacman -S --needed --noconfirm git base-devel
    BUILD_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$BUILD_DIR/yay"
    (
        cd "$BUILD_DIR/yay"
        makepkg -s --noconfirm
        sudo pacman -U --noconfirm yay-*.pkg.tar.zst
    )
    rm -rf "$BUILD_DIR"
fi

# Core desktop, shell, theming, and tool packages
CORE_PACKAGES=(
    # Compositor & Desktop Shell
    xdg-desktop-portal-umbriel-git
    umbriel-git
    noctalia

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

    # Optional
    zed
    helium-browser-bin
)

echo ":: Installing core packages..."
yay -S --needed --noconfirm --mflags --nocheck "${CORE_PACKAGES[@]}"
echo ":: Core packages installed successfully."
