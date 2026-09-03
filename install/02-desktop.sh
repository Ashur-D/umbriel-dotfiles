#!/bin/bash
set -euo pipefail

echo ":: [2/4] Installing AUR fonts, cursor & Wayland desktop stack..."

# Cursor & Font
yay -S --needed --noconfirm bibata-cursor-theme-bin maplemono-ttf

# Build Portal first so Umbriel has its portal backend ready
echo ":: Building xdg-desktop-portal-umbriel-git..."
yay -S --needed --noconfirm --mflags --nocheck xdg-desktop-portal-umbriel-git

# Build Compositor & Shell (--nocheck avoids headless Wayland display test errors)
echo ":: Building umbriel-git & noctalia-git..."
yay -S --needed --noconfirm --mflags --nocheck umbriel-git noctalia-git

echo ":: Desktop stack installed successfully."
