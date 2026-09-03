#!/bin/bash
set -euo pipefail

echo ":: [1/4] Installing base build tools & official packages..."

# Ensure Yay is installed
if ! command -v yay &>/dev/null; then
    echo ":: Installing yay from AUR..."
    sudo pacman -S --needed --noconfirm git base-devel
    BUILD_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$BUILD_DIR/yay"
    (cd "$BUILD_DIR/yay" && makepkg -si --noconfirm)
    rm -rf "$BUILD_DIR"
fi

# Base official packages & build prerequisites (Fast binary installation)
OFFICIAL_PKGS=(
    # Build tools for Wayland git packages
    base-devel git meson ninja pkgconf wayland-protocols tomlplusplus nlohmann-json
    wlroots0.20 cairo jemalloc lcms2 libdrm libglvnd libinput libxkbcommon pango pixman

    # Terminal, Shell & Tools
    kitty starship fastfetch yazi neovim chezmoi xdg-user-dirs

    # Audio & Power
    pipewire pipewire-pulse wireplumber playerctl power-profiles-daemon

    # Networking & Bluetooth
    bluez iwd impala

    # Capture, Clipboard & GTK
    wl-clipboard satty gpu-screen-recorder imagemagick adw-gtk-theme nwg-look
)

sudo pacman -S --needed --noconfirm "${OFFICIAL_PKGS[@]}"
echo ":: Base packages installed successfully."
