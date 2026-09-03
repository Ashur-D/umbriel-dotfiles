#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/colors.sh"

header "Step 5: System Services & User Directories"

# Standard XDG user directories
info "Updating XDG user directories (Downloads, Documents, Videos, etc.)..."
xdg-user-dirs-update

# Systemd system services
services=(
    bluetooth.service
    iwd.service
    power-profiles-daemon.service
)

info "Enabling and starting system services..."
for svc in "${services[@]}"; do
    if sudo systemctl enable --now "$svc" 2>/dev/null; then
        success "Service enabled: $svc"
    else
        warn "Could not enable $svc (may not be installed or supported on this hardware)"
    fi
done

success "Services configured!"
