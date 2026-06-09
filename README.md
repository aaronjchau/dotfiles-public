# Dotfiles

These are my personal config files for the terminal, Neovim, and a set of CLI tools, all matching the [Kanagawa](https://github.com/rebelot/kanagawa.nvim) color scheme. They work on macOS, Linux, and WSL.

The setup uses [GNU Stow](https://www.gnu.org/software/stow/) to symlink everything in this repo into your home folder. A gitleaks check runs on every commit to help prevent accidental commits of keys.

## Getting Started

1. Clone the repo into your home dir:

   ```bash
   git clone https://github.com/aaronjchau/dotfiles-public ~/dotfiles
   cd ~/dotfiles
   ```

2. Run the installer:

   ```bash
   ./install.sh
   ```

The installer detects your OS, installs the tools the configs need, links the config files into place, and downloads the Neovim and tmux plugins.

See below for a list of components that get installed. If you want a subset, see the Flags section.

### Compatibility 

I use macOS so most of the config was made with that in mind. If you want to run it on Windows, you can install WSL and the installer will work using the Linux path.

## Components


| Component | Description | macOS | Linux | Windows |
|---|---|:---:|:---:|:---:|
| `zsh` | Zsh shell, with vi keybindings | ✓ | ✓ | ✓ |
| `tmux` | Terminal multiplexer (`Ctrl-a` prefix) | ✓ | ✓ | ✓ |
| `nvim` | Neovim, set up with LazyVim | ✓ | ✓ | ✓ |
| `git` | Git config and global ignore file | ✓ | ✓ | ✓ |
| `starship` | Shell prompt | ✓ | ✓ | ✓ |
| `yazi` | Terminal file manager (also Neovim's file explorer) | ✓ | ✓ | ✓ |
| `lazygit` | Git in a terminal interface | ✓ | ✓ | ✓ |
| `btop` | System resource monitor | ✓ | ✓ | ✓ |
| _companions_ | fzf, fd, ripgrep, bat, eza, zoxide, git-delta, jq, node, python3, and the two zsh plugins | ✓ | ✓ | ✓ |
| `gh` / `gh-dash` | GitHub CLI and a PR dashboard | ✓ | ✓ | ✓ |
| `television` | Fuzzy finder you launch with `tv` | ✓ | ✓ | ✓ |
| `sesh` | tmux session manager | ✓ | ✓ | ✓ |
| _media previews_ | ffmpeg, imagemagick, chafa, poppler, 7zip (for yazi's image, video, PDF, and archive previews) | ✓ | ◐ | ◐ |
| `ghostty` | Terminal app | ✓ | — | — |
| `zed` | Zed code editor | ✓ | — | — |
| `aerospace` | Tiling window manager | ✓ | — | — |
| `karabiner` | Remaps Caps Lock to Esc / Ctrl | ✓ | — | — |

**✓** installed

**◐** installed but can be turned off with a flag

**—** not available on OS


### Flags

| Flag | Purpose |
|---|---|
| _(none)_ | Installs everything for your system: on a Mac, the CLI tools plus the desktop apps and fonts; on Linux/WSL, the CLI tools and the preview tools. |
| `--cli-only` | Installs only the CLI tools. On a Mac it skips the desktop apps, their fonts, and their config files. |
| `--no-media` | On Linux, skips the media-preview tools (useful on a server). |
| `--no-bootstrap` | Skips downloading the Neovim and tmux plugins (you can do that later). |
| `-y` / `--yes` | Answers "yes" to the one prompt automatically, so it can run unattended. |
| `--dry-run` | Shows what it would do without changing anything. |

If the tools are already installed and you just want the config files linked, you can skip the installer and run `setup.sh` directly: `./setup.sh` links everything, and `./setup.sh --minimal` links only the CLI configs.

## Keybindings

A quick reference to my (somewhat customized) keybindings for tmux, Neovim, yazi, AeroSpace, and the rest are in [docs/cheatsheet.md](docs/cheatsheet.md).

## License

[0BSD](https://opensource.org/license/0bsd) except for the `nvim/` folder, which is based on [LazyVim](https://github.com/LazyVim/LazyVim) and keeps its own Apache-2.0 license.
