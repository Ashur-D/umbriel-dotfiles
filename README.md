# umbriel-dotfiles

Arch Linux + [Umbriel](https://docs.noctalia.dev/umbriel/) compositor + Noctalia shell, managed with [chezmoi](https://www.chezmoi.io/).

## Install

On a fresh Arch install, as your regular user (not root):

```sh
sudo pacman -S --needed git chezmoi
chezmoi init --apply Ashur-D/umbriel-dotfiles
```

`init` asks which modules to enable and detects an Nvidia GPU, then applies everything: packages, drivers, services, and configs.

## Day to day

```sh
chezmoi diff     # what would change
chezmoi apply    # apply it
```

## Modules

Everything installable lives in `home/.chezmoidata/modules.toml`. A module bundles:

| Key | Meaning |
|---|---|
| `packages` | packages installed via yay-bin |
| `services` | systemd services enabled via systemctl (optional) |

`core` is always on. The rest are chosen at `init` (`desktop`, `gaming`, `dev`, `cli`, `system`, `media`, `rice`). Change the selection by running `chezmoi init` again.

<details>
<summary><strong>📦 View optional package list</strong></summary>

### 🌐 Daily Desktop Apps (`desktop`)

| Package | Description |
|---|---|
| `helium-browser-bin` | Minimal, lightweight Chromium-based browser |
| `discord` | Its discord |
| `obsidian` | Markdown knowledge base & personal note-taking |
| `localsend` | Cross-platform local network file sharing |
| `spotifast-bin` | Native Spotify client |

### 🎮 Gaming (`gaming`)

| Package | Description |
|---|---|
| `steam` | Valve Steam digital game launcher |
| `proton-cachyos-slr` | Performance-optimized Proton compatibility layer |

### 💻 Development & Code (`dev`)

| Package | Description |
|---|---|
| `zed` | High-performance, GPU-accelerated code editor |
| `lazygit` | Simple and fast terminal UI for Git |
| `git` | Fast, scalable distributed version control system |
| `openssh` | Secure shell remote access & cryptographic tools |
| `winboat` | Run Windows apps on Linux with seamless integration |
| `t3code-nightly-bin` | Desktop control surface for local coding agents |
| `gnome-boxes` | Simple GNOME application to access virtual systems |

### 🔍 Modern CLI & Navigation (`cli`)

| Package | Description |
|---|---|
| `eza` | Modern `ls` alternative with colors, icons & Git status |
| `zoxide` | Smarter, fast `cd` directory jumper tracking habits |
| `fzf` | Interactive command-line fuzzy finder |
| `fd` | Fast, user-friendly alternative to `find` |
| `ripgrep` | Blazing fast regex search tool replacing `grep` |
| `7zip` | used for zipping and unzipping files in yazi |

### 🛠️ System Management & Utilities (`system`)

| Package | Description |
|---|---|
| `btop` | Modern hardware resource & process monitor |
| `systemctl-tui` | Fast TUI for inspecting and controlling systemd units & logs |
| `systemd-manager-tui` | Interactive TUI manager for systemd services |
| `netsonar-bin` | Real-time terminal network traffic & packet monitor |
| `gdu` | Fast interactive terminal disk usage analyzer |
| `efibootmgr` | Tool to view and modify UEFI boot manager entries |
| `lact-git` | Linux GPU Configuration And Monitoring Tool |

### 🎨 Media & Viewers (`media`)

| Package | Description |
|---|---|
| `mpv` | High-performance, scriptable media and video player |
| `imv` | Fast, lightweight image viewer built for Wayland |
| `stremio` | hub for video content aggregation |

### 🌿 Terminal Rice & Visuals (`rice`)

| Package | Description |
|---|---|
| `catnap-git` | Fast, minimal aesthetic system fetch tool |
| `weathr` | Terminal weather forecast with live ASCII animations |
| `rustormy-bin` | Clean and minimal terminal weather fetcher |
| `cbonsai` | Procedural bonsai tree generator in the terminal |
| `terminal-rain-lightning` | Matrix digital rain effect with thunder and lightning |
| `scope-tui` | Real-time audio oscilloscope & vectorscope in the terminal |
| `astroterm` | Interactive night-sky planetarium simulator for CLI |
| `asciinema` | Lightweight terminal session recorder and sharer |

</details>
**Add a module:** add a `[modules.<name>]` block here.
**Remove one:** delete its block. No script needs editing.

If you previously ran chezmoi on an older version of this repo, run `chezmoi init` once to update your machine settings.

## Layout

| Path | Purpose |
|---|---|
| `home/.chezmoidata/modules.toml` | Modules, Nvidia packages, launcher-hidden apps |
| `home/.chezmoi.toml.tmpl` | `init` questions and Nvidia detection |
| `home/.chezmoiignore` | Ignored runtime/generated files and local notes |
| `home/.chezmoiscripts/` | `install.sh.tmpl` (yay-bin, packages, services, launcher), `yazi-plugins.sh.tmpl` |
| `home/dot_config/…` | App configs |

## Notes

* **Networking:** Managed via NetworkManager (Ethernet + Wi-Fi). If `iwd` or `systemd-networkd` is already running on the machine, the install script skips NetworkManager and prints instructions to prevent dropping your connection.
* **Wallpapers:** Noctalia provides a built-in default wallpaper out of the box. Drop or clone any wallpapers into `~/Pictures/wallpapers` to use them in Noctalia's wallpaper picker.
