#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
source "$SCRIPT_DIR/colors.sh"

header "Umbriel & Noctalia Desktop Installer"

# 1. Setup logging
mkdir -p "$REPO_DIR/logs"
LOGFILE="$REPO_DIR/logs/install_$(date +"%Y%m%d_%H%M%S").log"
exec > >(tee -a "$LOGFILE") 2>&1
info "Logging installation to: $LOGFILE"

# 2. Sudo keep-alive
info "Requesting sudo privileges..."
sudo -v
while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &

# 3. System update
info "Performing system synchronization (pacman -Syu)..."
sudo pacman -Syu --noconfirm

# 4. Run steps sequentially
"$SCRIPT_DIR/01-aur-helper.sh"
"$SCRIPT_DIR/02-cachyos.sh"
"$SCRIPT_DIR/03-nvidia.sh"
"$SCRIPT_DIR/04-packages.sh"
"$SCRIPT_DIR/05-services.sh"
"$SCRIPT_DIR/06-dotfiles.sh"

header "✨ Installation Complete! ✨"
echo -e "${GREEN}All packages, drivers, and dotfiles have been installed and configured.${RESET}"
echo -e "${YELLOW}A reboot is recommended to start the new system services and graphics stack.${RESET}\n"
