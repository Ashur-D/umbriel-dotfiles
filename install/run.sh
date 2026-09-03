#!/bin/bash
set -euo pipefail

# Require regular user (not root) so makepkg/yay can build packages
if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: Please run this script as your regular user (not with sudo)."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Setup logging
mkdir -p "$REPO_DIR/logs"
LOG_FILE="$REPO_DIR/logs/install_$(date +'%Y%m%d_%H%M%S').log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo ":: Starting installation. Log: $LOG_FILE"

# Sudo authentication & keep-alive
echo ":: Authenticating sudo..."
sudo -v
while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &

# Execute 3 stages in order
"$SCRIPT_DIR/01-packages.sh"
"$SCRIPT_DIR/02-system.sh"
"$SCRIPT_DIR/03-dotfiles.sh"
"$SCRIPT_DIR/04-optional.sh"

echo ":: ✨ Installation completed successfully!"
echo ":: Log saved to: $LOG_FILE"
