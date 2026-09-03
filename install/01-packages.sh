#!/bin/bash
set -euo pipefail

echo ":: [1/3] Installing yay and core package stack..."

# Ensure Yay and gum are installed first
if ! command -v yay &>/dev/null; then
    echo ":: Installing yay from AUR..."
    sudo pacman -S --needed --noconfirm git base-devel
    BUILD_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$BUILD_DIR/yay"
    (cd "$BUILD_DIR/yay" && makepkg -si --noconfirm)
    rm -rf "$BUILD_DIR"
fi

# Ensure gum is present for interactive selection
if ! command -v gum &>/dev/null; then
    sudo pacman -S --needed --noconfirm gum
fi

# Core desktop, shell, theming, and tool packages
CORE_PACKAGES=(
    # Compositor & Desktop Shell
    xdg-desktop-portal-umbriel-git
    umbriel-git
    noctalia-git

    # Terminal, Shell & Tools
    kitty starship fastfetch yazi neovim chezmoi xdg-user-dirs

    # Audio & Power
    pipewire pipewire-pulse wireplumber playerctl power-profiles-daemon

    # Networking & Bluetooth
    bluez iwd

    # Capture, Fonts & GTK
    wl-clipboard satty gpu-screen-recorder bibata-cursor-theme-bin maplemono-ttf adw-gtk-theme
)

# Optional Packages (Selectable via gum)
OPTIONAL_LIST=(
    "nwg-look                    GTK3/4 settings and theme editor"
    "mpv                         Lightweight CLI/GUI video player"
    "imv                         Image viewer for Wayland"
    "python-gobject              Python GObject bindings (power-profiles-daemon / GTK)"
    "btop                        Modern resource monitor"
    "zen-browser-bin             Fast, privacy-focused browser"
    "helium-browser-bin          Minimal browser"
    "vesktop-bin                 Discord client with Wayland screenshare & Vencord"
    "obsidian                    Markdown knowledge base & notes"
    "localsend                   Local cross-platform file sharing"
    "fastpotify-bin              Spotify TUI client"
    "thunar                      GTK graphical file manager"
    "steam                       Gaming platform"
    "gamescope                   Micro-compositor for gaming"
    "proton-cachyos              Optimized Proton compatibility tool"
    "git                         Version control system"
    "lazygit                     TUI for Git"
    "zed                         High-performance GUI code editor"
    "openssh                     SSH client & server"
    "eza                         Modern ls replacement"
    "fd                          Fast alternative to find"
    "zoxide                      Smarter cd directory jumper"
    "fzf                         Command-line fuzzy finder"
    "bottom                      Alternative graphical process monitor"
    "systemctl-tui               Manage systemd services in a TUI"
    "stacer-bin                  System optimizer & GUI monitor"
    "netsonar-bin                Network monitoring tool"
    "gdu                         Fast disk usage analyzer"
    "ncdu                        Disk usage analyzer (ncurses)"
    "efibootmgr                  Modify UEFI boot entries"
    "pachub                      Front-end for Pacman/AUR"
    "dust                        Intuitive du disk usage analyzer in Rust"
    "astroterm                   Terminal planetarium"
    "asciinema                   Terminal session recorder"
    "cbonsai                     Bonsai tree generator"
    "catnap-git                  Fast system fetch tool"
    "stormy-bin                  Terminal weather fetch"
    "terminaltexteffects         Visual text animation effects"
    "scope-tui                   Oscilloscope/vectorscope for terminal"
    "weathr                      Terminal weather app with ASCII animation"
    "terminal-rain-lightning-git Terminal matrix rain & lightning"
)

echo ":: Installing core packages..."
yay -S --needed --noconfirm --mflags --nocheck "${CORE_PACKAGES[@]}"

# Interactive Optional Package Selection
echo ""
echo ":: Choose optional packages to install (SPACE/TAB to select, ENTER to confirm, ESC to skip):"
SELECTED_ITEMS=$(printf "%s\n" "${OPTIONAL_LIST[@]}" | gum choose --no-limit --height 20 || true)

if [ -n "$SELECTED_ITEMS" ]; then
    # Extract package names (first column before description)
    PKGS_TO_INSTALL=()
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        pkg=$(echo "$line" | awk '{print $1}')
        PKGS_TO_INSTALL+=("$pkg")
    done <<< "$SELECTED_ITEMS"

    echo ":: Installing selected optional packages: ${PKGS_TO_INSTALL[*]}"
    yay -S --needed --noconfirm --mflags --nocheck "${PKGS_TO_INSTALL[@]}"
else
    echo ":: No optional packages selected. Skipping."
fi

echo ":: Package installation phase complete."
