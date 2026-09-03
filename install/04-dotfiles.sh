#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo ":: [4/4] Applying dotfiles, plugins, and launcher settings..."

# 1. Apply dotfiles via Chezmoi
mkdir -p "$HOME/.config/chezmoi"
echo "sourceDir = \"$REPO_DIR\"" > "$HOME/.config/chezmoi/chezmoi.toml"
chezmoi apply --force

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
