# umbriel-dotfiles

Arch Linux + [Umbriel](https://docs.noctalia.dev/umbriel/) compositor + Noctalia shell, managed with [chezmoi](https://www.chezmoi.io/).

## Install

On a fresh Arch install, as your regular user (not root):

```sh
sudo pacman -S --needed git chezmoi
chezmoi init --apply Ashur-D/umbriel-dotfiles
```

`init` asks once which optional package groups to install, detects an Nvidia GPU, then applies everything: packages, drivers, services, networking, configs and wallpapers.

## Day to day

```sh
chezmoi diff     # what would change
chezmoi apply    # apply it
```

Edit `home/.chezmoidata/packages.toml` to add or remove packages; the install script re-runs automatically when the list changes.

## Layout

| Path | Purpose |
|---|---|
| `home/.chezmoidata/packages.toml` | Package lists (`core`, optional groups, Nvidia) and launcher-hidden apps |
| `home/.chezmoi.toml.tmpl` | `init` questions and Nvidia detection |
| `home/.chezmoiscripts/` | `10-packages` (yay + packages), `20-system` (services, networking, hidden apps) |
| `home/.chezmoiexternal.toml` | Wallpapers git repo, cloned to `~/Pictures/wallpapers` |
| `home/dot_config/…` | App configs |

Files prefixed `create_` (Noctalia, Zed, starship) are written once and never overwritten, because those apps edit their own config.

## Optional package groups

Chosen at `init` via `packageGroups`: `desktop`, `gaming`, `dev`, `cli`, `system`, `media`, `rice`. See `packages.toml` for contents. Change the selection later in `~/.config/chezmoi/chezmoi.toml`.
