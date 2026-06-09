#!/usr/bin/env bash
# setup.sh — bootstrap these dotfiles on a machine. Idempotent: safe to re-run.
#
#   ./setup.sh            # symlink everything + wire up the gitleaks hook + tpm
#   ./setup.sh --brew     # also run `brew bundle` first (installs all formulae/casks)
#   ./setup.sh --minimal  # stow the CLI packages only — skips the macOS-only GUI configs
#                         #   (aerospace karabiner ghostty zed). Use on Linux / a remote box.
#   ./setup.sh --tools    # install shell companions (starship fzf zoxide + zsh
#                         #   plugins + fd) via the OS package manager; pair with --minimal
#
# Stow targets $HOME explicitly (-t "$HOME"), so it works no matter where you
# clone the repo. nvim is the one folded package (a single dir symlink).
set -euo pipefail
cd "$(dirname "$0")"
bold() { printf '\033[1m==> %s\033[0m\n' "$1"; }

# Install the shell companions the configs expect (starship/fzf/zoxide, the two zsh
# plugins, fd) via whatever package manager is present. starship isn't packaged
# everywhere, so fall back to its official installer.
install_tools() {
  if command -v brew >/dev/null; then
    bold "Installing companions via Homebrew"
    brew install starship fzf zoxide zsh-autosuggestions zsh-syntax-highlighting fd
    return
  fi
  local SUDO=""
  if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null; then SUDO="sudo"; fi
  local need_starship=0
  if command -v apt-get >/dev/null; then
    bold "Installing companions via apt"
    $SUDO apt-get update -qq
    $SUDO apt-get install -y zsh-autosuggestions zsh-syntax-highlighting fzf zoxide fd-find
    need_starship=1
  elif command -v dnf >/dev/null; then
    bold "Installing companions via dnf"
    $SUDO dnf install -y zsh-autosuggestions zsh-syntax-highlighting fzf zoxide fd-find starship || need_starship=1
  elif command -v pacman >/dev/null; then
    bold "Installing companions via pacman"
    $SUDO pacman -S --needed --noconfirm zsh-autosuggestions zsh-syntax-highlighting fzf zoxide fd starship
  elif command -v zypper >/dev/null; then
    bold "Installing companions via zypper"
    $SUDO zypper install -y zsh-autosuggestions zsh-syntax-highlighting fzf zoxide fd starship || need_starship=1
  else
    echo "No supported package manager (brew/apt/dnf/pacman/zypper) — install the companions by hand." >&2
    return
  fi
  # Debian/Fedora package fd as `fdfind`; expose it as `fd` on $HOME/.local/bin (the .zshrc PATH).
  if ! command -v fd >/dev/null && command -v fdfind >/dev/null; then
    mkdir -p "$HOME/.local/bin" && ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
  if [ "$need_starship" = 1 ] && ! command -v starship >/dev/null; then
    bold "Installing starship via its official installer"
    mkdir -p "$HOME/.local/bin"
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin" \
      || echo "  ! starship install failed (often a transient GitHub CDN 5xx) — re-run: ./setup.sh --tools" >&2
  fi
}

BREW=0
MINIMAL=0
TOOLS=0
for arg in "$@"; do
  case "$arg" in
    --brew) BREW=1 ;;
    --minimal) MINIMAL=1 ;;
    --tools) TOOLS=1 ;;
    *) echo "unknown flag: $arg" >&2; exit 1 ;;
  esac
done

# 0. Prerequisites: GNU Stow always; Homebrew only when --brew installs the Brewfile.
if [ "$BREW" = 1 ] && ! command -v brew >/dev/null; then
  echo "Install Homebrew first: https://brew.sh"; exit 1
fi
if ! command -v stow >/dev/null; then
  if command -v brew >/dev/null; then
    bold "Installing stow"; brew install stow
  else
    echo "GNU Stow required — install it (apt/dnf/pacman/brew install stow), then re-run."; exit 1
  fi
fi

# 1. (optional) install everything from the Brewfile
if [ "$BREW" = 1 ]; then
  bold "brew bundle (this takes a while)"
  brew bundle --file=Brewfile
fi

# 2. Symlink packages into $HOME. If stow reports a CONFLICT, a real file already
#    exists at the target (e.g. a default ~/.zshrc) — remove it and re-run.
bold "Stowing packages"
if [ "$MINIMAL" = 1 ]; then
  # CLI packages only — the macOS-only GUI configs (aerospace karabiner ghostty zed) are skipped.
  stow --no-folding -t "$HOME" zsh tmux git starship btop gh gh-dash television sesh yazi lazygit
  stow -t "$HOME" nvim
else
  stow --no-folding -t "$HOME" zsh tmux git starship btop aerospace karabiner ghostty zed gh gh-dash television sesh yazi lazygit
  stow -t "$HOME" nvim
fi

# 3. Activate the gitleaks pre-commit hook
git config core.hooksPath .githooks
bold "gitleaks pre-commit hook active"

# 4. tmux plugin manager
[ -d "$HOME/.tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

# 5. yazi plugins/flavors + local patches (only if yazi is installed)
if command -v ya >/dev/null; then
  bold "Installing yazi packages + applying local patches"
  ya pkg install || true
  [ -x ./scripts/apply-patches.sh ] && ./scripts/apply-patches.sh || true
fi

# 6. (optional) shell companion tools — last, so a tool-install hiccup never blocks the symlinks
if [ "$TOOLS" = 1 ]; then install_tools; fi

cat <<'NOTE'

✅ Symlinks, the gitleaks hook, and tpm are set up.

Remaining steps you do by hand:
  • brew bundle --file=Brewfile     # if you didn't pass --brew above
  • gh auth login                   # restores ~/.config/gh/hosts.yml
  • ./scripts/macos-defaults.sh     # macOS system tweaks
  • open -a AeroSpace               # grant Accessibility, then it self-starts
  • inside tmux: prefix + I         # fetch tmux plugins
NOTE
