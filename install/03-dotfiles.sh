#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo ":: [3/3] Applying dotfiles, plugins, and launcher settings..."

# 1. Apply dotfiles via Chezmoi
mkdir -p "$HOME/.config/chezmoi"
echo "sourceDir = \"$REPO_DIR\"" > "$HOME/.config/chezmoi/chezmoi.toml"
chezmoi apply --force

# Enable Nvidia environment variables if Nvidia GPU is present
if lspci 2>/dev/null | grep -Ei "vga|3d" | grep -qi "nvidia"; then
    if [ -f "$HOME/.config/umbriel/general.toml" ]; then
        echo ":: Nvidia GPU detected. Enabling Nvidia environment variables in Umbriel config..."
        sed -i 's/^#\s*LIBVA_DRIVER_NAME/LIBVA_DRIVER_NAME/' "$HOME/.config/umbriel/general.toml"
        sed -i 's/^#\s*__GLX_VENDOR_LIBRARY_NAME/__GLX_VENDOR_LIBRARY_NAME/' "$HOME/.config/umbriel/general.toml"
    fi
fi

# 2. Install Yazi plugins (package.toml now in place)
if command -v ya &>/dev/null; then
    echo ":: Installing Yazi plugins from package.toml..."
    ya pkg install || true
fi

# 3. Hide cluttered utility apps from launcher
echo ":: Hiding utility apps from application launcher..."
mkdir -p "$HOME/.local/share/applications"
HIDDEN_APPS=(
    "bssh" "bvnc" "avahi-discover" "rofi-theme-selector"
    "thunar-bulk-rename" "thunar-settings" "wiremix" "cmake-gui"
    "org.gnupg.pinentry-qt" "xdg-desktop-portal-gdk" "xgps"
    "xgpsspeed" "qv4l2" "qvidcap" "lstopo"
)
for app in "${HIDDEN_APPS[@]}"; do
    global_file="/usr/share/applications/${app}.desktop"
    local_file="$HOME/.local/share/applications/${app}.desktop"
    if [ -f "$global_file" ]; then
        cp "$global_file" "$local_file"
        if ! grep -q "^NoDisplay=true" "$local_file"; then
            echo "NoDisplay=true" >> "$local_file"
        fi
    fi
done

echo ":: Dotfiles and post-install configuration complete."
