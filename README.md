# umbriel-dotfiles

Arch Linux + [Umbriel](https://docs.noctalia.dev/umbriel/) compositor + Noctalia shell, managed with [chezmoi](https://www.chezmoi.io/).

## Install

On a fresh Arch install, as your regular user (not root):

```sh
sudo pacman -S --needed git chezmoi
chezmoi init --apply Ashur-D/umbriel-dotfiles
```

`init` asks which modules to enable and detects an Nvidia GPU, then applies everything: packages, drivers, services, networking, configs and wallpapers.

## Day to day

```sh
chezmoi diff     # what would change
chezmoi apply    # apply it
```

## Modules

Everything installable lives in `home/.chezmoidata/modules.toml`. A module bundles:

| Key | Meaning |
|---|---|
| `packages` | installed by the packages script |
| `services` | enabled by the system script (optional) |
| `config` | target path of its config, skipped when the module is off (optional) |

`core` is always on. The rest are chosen at `init` (`nvim`, `yazi`, `zed`, `fastfetch`, `cli`, `dev`, `desktop`, `gaming`, `system`, `media`, `rice`). Change the selection by running `chezmoi init` again.

**Add an app:** add a `[modules.<name>]` block plus its `home/dot_config/<name>/` folder.
**Remove one:** delete both. No script or ignore file needs editing.

If you already have a chezmoi config from an older version of this repo, run `chezmoi init` once so it picks up `enabled` and `hasNvidia`; until then, templates fail with a missing-key error.

## Layout

| Path | Purpose |
|---|---|
| `home/.chezmoidata/modules.toml` | Modules, Nvidia packages, launcher-hidden apps |
| `home/.chezmoi.toml.tmpl` | `init` questions and Nvidia detection |
| `home/.chezmoiignore.tmpl` | Skips configs of disabled modules, plus generated files |
| `home/.chezmoiscripts/` | `10-packages` (yay + packages), `20-system` (services, networking, hidden apps), `30-yazi-plugins` |
| `home/.chezmoiexternal.toml` | Wallpapers git repo, cloned to `~/Pictures/wallpapers` |
| `home/dot_config/…` | App configs |

Files prefixed `create_` (Noctalia, Zed, starship) are written once and never overwritten, because those apps edit their own config.
