#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/colors.sh"

header "Step 4: System, Shell & Desktop Packages"

# Base & Wayland compositor stack
core_packages=(
    # --- Compositor & Shell ---
    umbriel-git                     # Fast modern Wayland compositor
    xdg-desktop-portal-umbriel-git   # Portal backend for Umbriel
    noctalia-git                    # Desktop shell, bar, notifications, launcher
    
    # --- Terminal & Shell ---
    kitty                           # GPU-accelerated terminal
    starship                        # Cross-shell prompt
    fastfetch                       # System info display
    yazi                            # Terminal file manager
    neovim                          # Text editor
    
    # --- Audio & Media ---
    pipewire
    pipewire-pulse
    pipewire-alsa
    wireplumber
    wiremix
    playerctl
    mpv
    imv
    
    # --- Hardware & System ---
    power-profiles-daemon
    python-gobject
    btop
    brightnessctl
    xdg-user-dirs
    
    # --- Networking & Bluetooth ---
    iwd
    impala
    bluez
    bluetui
    
    # --- Theming & Visuals ---
    bibata-cursor-theme-bin
    adw-gtk-theme
    maplemono-ttf
    
    # --- Capture & Clipboard ---
    wl-clipboard
    cliphist
    wl-clip-persist
    satty
    gpu-screen-recorder
    gpu-screen-recorder-ui
    imagemagick
    
    # --- Dotfiles management ---
    chezmoi
)

info "Installing core system packages..."
yay -S --needed --noconfirm "${core_packages[@]}"
success "Core packages installed!"

# Optional apps prompt
echo -ne "\n${CYAN}Would you like to install optional desktop apps (Steam, Zed, Discord/Vesktop, Zen Browser, Obsidian)? [y/N]: ${RESET}"
read -r apps_choice

if [[ "$apps_choice" =~ ^[Yy]$ ]]; then
    opt_packages=(
        zen-browser-bin
        vesktop-bin
        obsidian
        zed
        steam
        gamescope
        lazygit
        gum
        fzf
        zoxide
        eza
        fd
    )
    info "Installing optional packages..."
    yay -S --needed --noconfirm "${opt_packages[@]}"
    success "Optional packages installed!"
fi
