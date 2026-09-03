#!/bin/bash
set -euo pipefail

echo ":: [2/3] Configuring hardware drivers and system services..."

# Detect installed kernels and auto-install Nvidia drivers + matching headers if Nvidia GPU exists
INSTALLED_KERNELS=$(pacman -Qq | grep -E '^linux(-[a-z0-9]+)?$' | grep -v 'firmware' || true)

if lspci 2>/dev/null | grep -Ei "vga|3d" | grep -qi "nvidia"; then
    echo ":: Nvidia GPU detected. Installing drivers and matching headers..."
    NVIDIA_PKGS=(nvidia-dkms nvidia-utils lib32-nvidia-utils egl-wayland libva-nvidia-driver)
    for k in $INSTALLED_KERNELS; do
        NVIDIA_PKGS+=("${k}-headers")
    done
    sudo pacman -S --needed --noconfirm "${NVIDIA_PKGS[@]}"
fi

# Standard user directories
xdg-user-dirs-update

# Enable essential system services
echo ":: Enabling network, bluetooth, and power services..."
sudo systemctl enable --now \
    bluetooth.service \
    iwd.service \
    systemd-networkd.service \
    systemd-resolved.service \
    power-profiles-daemon.service 2>/dev/null || true

# Configure greetd with noctalia-greeter
echo ":: Configuring greetd with Noctalia Greeter..."
sudo mkdir -p /etc/greetd
sudo tee /etc/greetd/config.toml >/dev/null << 'EOF'
[terminal]
vt = 1

[default_session]
command = "env WLR_NO_HARDWARE_CURSORS=1 noctalia-greeter-session"
user = "greeter"
EOF

# Ensure greeter permissions, groups, and state directory exist
sudo usermod -aG video,render,input greeter 2>/dev/null || true
sudo mkdir -p /var/lib/noctalia-greeter
sudo chown -R greeter:greeter /var/lib/noctalia-greeter 2>/dev/null || true
sudo systemd-tmpfiles --create /usr/lib/tmpfiles.d/noctalia-greeter.conf 2>/dev/null || true

# Enable greetd display manager
sudo systemctl enable greetd.service

echo ":: System and hardware configuration complete."
