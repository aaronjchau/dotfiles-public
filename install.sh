#!/usr/bin/env bash
# install.sh — one clone + one command bootstrap of a working terminal
# (zsh + starship + companions), tmux, and Neovim on macOS or Linux.
# Windows: run this inside WSL2 (an Ubuntu distro) — the Linux path applies verbatim.
#
# A thin orchestrator on top of ./setup.sh:
#   - detect OS / distro / package manager
#   - install the CLI tool set (best-effort; a single tool failing never aborts)
#   - delegate stow + gitleaks hook + tpm clone to ./setup.sh
#   - bootstrap plugins headlessly (nvim Lazy! sync, tpm install_plugins)
#
# Two tiers (see the README table): the CLI tools install on every platform; the macOS GUI
# apps (ghostty, zed, aerospace, karabiner) install only on macOS, and only without --cli-only.
# On Linux/WSL the GUI tier is out of scope — only the cross-platform CLI configs are stowed.
#
# Usage:
#   ./install.sh                # CLI tools + (macOS) GUI casks/fonts, then stow + bootstrap
#   ./install.sh --cli-only     # CLI tools only — macOS skips the GUI casks + their configs
#   ./install.sh --no-media     # Linux: skip yazi's media-preview tools (ffmpeg, imagemagick, …)
#   ./install.sh --no-bootstrap # skip the headless nvim/tpm plugin bootstrap
#   ./install.sh -y | --yes     # non-interactive (assume yes for the chsh prompt)
#   ./install.sh --dry-run      # print detected env + planned commands, run nothing
set -uo pipefail
cd "$(dirname "$0")" || exit 1
REPO_DIR="$(pwd)"

bold() { printf '\033[1m==> %s\033[0m\n' "$1"; }
info() { printf '    %s\n' "$1"; }
warn() { printf '\033[33m  ! %s\033[0m\n' "$1" >&2; }
ok()   { printf '\033[32m  ✓ %s\033[0m\n' "$1"; }

INSTALLED=""; SKIPPED=""; FAILED=""
note_installed() { INSTALLED="$INSTALLED $1"; }
note_skipped()   { SKIPPED="$SKIPPED $1"; }
note_failed()    { FAILED="$FAILED $1"; }

# ── flags ──
CLI_ONLY=0; NO_BOOTSTRAP=0; ASSUME_YES=0; DRY_RUN=0; NO_MEDIA=0
for arg in "$@"; do
  case "$arg" in
    --cli-only|--no-gui|--essential-only|--no-optional) CLI_ONLY=1 ;;
    --no-media|--no-previews) NO_MEDIA=1 ;;
    --no-bootstrap) NO_BOOTSTRAP=1 ;;
    -y|--yes)       ASSUME_YES=1 ;;
    --dry-run)      DRY_RUN=1 ;;
    -h|--help)      sed -n '2,22p' "$(basename "$0")"; exit 0 ;;
    *) echo "unknown flag: $arg (try --help)" >&2; exit 1 ;;
  esac
done

# run CMD, or just print it under --dry-run
run() { if [ "$DRY_RUN" = 1 ]; then printf '    [dry-run] %s\n' "$*"; else "$@"; fi; }
have() { command -v "$1" >/dev/null 2>&1; }

# ── detection ──
OS="$(uname -s)"; ARCH="$(uname -m)"; PM=""; SUDO=""
[ "$(id -u)" -ne 0 ] && have sudo && SUDO="sudo"
if [ "$OS" = "Darwin" ]; then PM="brew"
elif have apt-get; then PM="apt"
elif have dnf;     then PM="dnf"
elif have pacman;  then PM="pacman"
elif have zypper;  then PM="zypper"
fi

# ~/.local/bin holds shims + release-tarball binaries; the stowed .zprofile adds it to PATH.
LOCALBIN="$HOME/.local/bin"
mkdir -p "$LOCALBIN" 2>/dev/null || true
case ":$PATH:" in *":$LOCALBIN:"*) : ;; *) export PATH="$LOCALBIN:$PATH" ;; esac

APT_UPDATED=0
pkg_install() {
  case "$PM" in
    apt)    [ "$APT_UPDATED" = 0 ] && { run $SUDO apt-get update -qq || true; APT_UPDATED=1; }
            run $SUDO apt-get install -y "$@" ;;
    dnf)    run $SUDO dnf install -y "$@" ;;
    pacman) run $SUDO pacman -S --needed --noconfirm "$@" ;;
    zypper) run $SUDO zypper install -y "$@" ;;
    *) return 1 ;;
  esac
}

# make_shim <wanted> <actual> — Debian/Fedora ship fd/bat as fdfind/batcat; configs call fd/bat.
make_shim() {
  if ! have "$1" && have "$2"; then
    run ln -sf "$(command -v "$2")" "$LOCALBIN/$1"; ok "shim $1 -> $2"
  fi
}

# ess <name> <check-bin> <distro-pkgs...> — install via distro PM; run FALLBACK_FN on failure.
FALLBACK_FN=""
ess() {
  local name="$1" check="$2"; shift 2
  local fb="$FALLBACK_FN"; FALLBACK_FN=""
  if have "$check"; then ok "$name (present)"; note_installed "$name"; return 0; fi
  bold "Installing $name"
  if pkg_install "$@"; then note_installed "$name"; return 0; fi
  if [ -n "$fb" ] && "$fb"; then note_installed "$name (fallback)"; return 0; fi
  warn "$name could not be installed automatically"; note_failed "$name"; return 0
}

# ── fallback closures ──
fallback_starship() {
  bold "Installing starship via official installer"
  curl -fsSL https://starship.rs/install.sh 2>/dev/null | sh -s -- -y -b "$LOCALBIN" 2>/dev/null
}

NVIM_MIN_MINOR=11
nvim_too_old() { # 0/true if missing or below 0.<MIN>
  have nvim || return 0
  local v maj min
  v="$(nvim --version 2>/dev/null | head -1 | sed -E 's/^NVIM v?([0-9]+\.[0-9]+).*/\1/')"
  maj="${v%%.*}"; min="${v##*.}"
  [ -z "$maj" ] && return 0
  [ "$maj" -gt 0 ] && return 1
  [ "$min" -ge "$NVIM_MIN_MINOR" ] && return 1
  return 0
}
install_neovim_release() {
  local tarball dir
  case "$ARCH" in
    x86_64|amd64)  tarball="nvim-linux-x86_64.tar.gz"; dir="nvim-linux-x86_64" ;;
    aarch64|arm64) tarball="nvim-linux-arm64.tar.gz";  dir="nvim-linux-arm64" ;;
    *) warn "unknown arch '$ARCH' for neovim release"; return 1 ;;
  esac
  bold "Installing current Neovim from GitHub release ($dir)"
  local tmp; tmp="$(mktemp -d)"
  if ! run curl -fsSL -o "$tmp/$tarball" "https://github.com/neovim/neovim/releases/latest/download/$tarball"; then
    warn "neovim download failed"; rm -rf "$tmp"; return 1; fi
  run $SUDO rm -rf "/opt/$dir"
  if ! run $SUDO tar -C /opt -xzf "$tmp/$tarball"; then warn "neovim extract failed"; rm -rf "$tmp"; return 1; fi
  run $SUDO ln -sf "/opt/$dir/bin/nvim" /usr/local/bin/nvim
  rm -rf "$tmp"; have nvim
}
install_neovim() {
  if ! nvim_too_old; then ok "neovim (current)"; note_installed "neovim"; return; fi
  # Arch/Fedora repos are usually current; try them, then verify the floor.
  if [ "$PM" = "pacman" ] || [ "$PM" = "dnf" ]; then
    pkg_install neovim >/dev/null 2>&1 || true
    if ! nvim_too_old; then ok "neovim (distro)"; note_installed "neovim"; return; fi
    warn "distro neovim too old for LazyVim — using the GitHub release"
  fi
  if install_neovim_release; then note_installed "neovim (release)"
  else warn "neovim install failed — LazyVim needs a current nvim on PATH"; note_failed "neovim"; fi
}

install_lazygit_release() {
  bold "Installing lazygit from GitHub release"
  local at; case "$ARCH" in x86_64|amd64) at="x86_64" ;; aarch64|arm64) at="arm64" ;; *) return 1 ;; esac
  local ver tmp
  ver="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest 2>/dev/null \
        | sed -nE 's/.*"tag_name": *"v([^"]+)".*/\1/p' | head -1)"
  [ -z "$ver" ] && return 1
  tmp="$(mktemp -d)"
  if run curl -fsSL -o "$tmp/lg.tar.gz" \
      "https://github.com/jesseduffield/lazygit/releases/download/v${ver}/lazygit_${ver}_Linux_${at}.tar.gz" \
     && run tar -C "$tmp" -xzf "$tmp/lg.tar.gz" lazygit; then
    run install "$tmp/lazygit" "$LOCALBIN/lazygit"; rm -rf "$tmp"; have lazygit
  else rm -rf "$tmp"; return 1; fi
}
install_delta_release() {
  bold "Installing git-delta from GitHub release"
  local at; case "$ARCH" in
    x86_64|amd64)  at="x86_64-unknown-linux-gnu" ;;
    aarch64|arm64) at="aarch64-unknown-linux-gnu" ;; *) return 1 ;; esac
  local ver tmp bin
  ver="$(curl -fsSL https://api.github.com/repos/dandavison/delta/releases/latest 2>/dev/null \
        | sed -nE 's/.*"tag_name": *"([^"]+)".*/\1/p' | head -1)"
  [ -z "$ver" ] && return 1
  tmp="$(mktemp -d)"
  if run curl -fsSL -o "$tmp/d.tar.gz" \
      "https://github.com/dandavison/delta/releases/download/${ver}/delta-${ver}-${at}.tar.gz" \
     && run tar -C "$tmp" -xzf "$tmp/d.tar.gz"; then
    bin="$(find "$tmp" -name delta -type f 2>/dev/null | head -1)"
    [ -n "$bin" ] && run install "$bin" "$LOCALBIN/delta"; rm -rf "$tmp"; have delta
  else rm -rf "$tmp"; return 1; fi
}
install_eza_fallback() { have cargo && { bold "eza via cargo"; run cargo install eza && have eza; }; }
install_yazi_release() {
  bold "Installing yazi from GitHub release"
  local at; case "$ARCH" in
    x86_64|amd64)  at="x86_64-unknown-linux-gnu" ;;
    aarch64|arm64) at="aarch64-unknown-linux-gnu" ;; *) return 1 ;; esac
  have unzip || pkg_install unzip >/dev/null 2>&1 || return 1
  local ver tmp d
  ver="$(curl -fsSL https://api.github.com/repos/sxyazi/yazi/releases/latest 2>/dev/null \
        | sed -nE 's/.*"tag_name": *"v([^"]+)".*/\1/p' | head -1)"
  [ -z "$ver" ] && return 1
  tmp="$(mktemp -d)"
  if run curl -fsSL -o "$tmp/yazi.zip" \
      "https://github.com/sxyazi/yazi/releases/download/v${ver}/yazi-${at}.zip" \
     && run unzip -q "$tmp/yazi.zip" -d "$tmp"; then
    d="$(find "$tmp" -maxdepth 1 -type d -name 'yazi-*' | head -1)"
    [ -n "$d" ] && { run install "$d/yazi" "$LOCALBIN/yazi"; run install "$d/ya" "$LOCALBIN/ya" 2>/dev/null || true; }
    rm -rf "$tmp"; have yazi
  else rm -rf "$tmp"; return 1; fi
}
install_yazi_fallback() {
  install_yazi_release && return 0
  have cargo && { bold "yazi via cargo"; run cargo install --locked yazi-fm yazi-cli && have yazi; }
}

# sesh / television / gh-dash aren't in the distro repos and we don't assume go/cargo —
# install the prebuilt release binaries (same pattern as nvim/yazi/lazygit above).
install_sesh_release() {
  bold "Installing sesh from GitHub release"
  local at; case "$ARCH" in x86_64|amd64) at="Linux_x86_64" ;; aarch64|arm64) at="Linux_arm64" ;; *) return 1 ;; esac
  local ver tmp bin
  ver="$(curl -fsSL https://api.github.com/repos/joshmedeski/sesh/releases/latest 2>/dev/null \
        | sed -nE 's/.*"tag_name": *"v([^"]+)".*/\1/p' | head -1)"
  [ -z "$ver" ] && return 1
  tmp="$(mktemp -d)"
  if run curl -fsSL -o "$tmp/sesh.tar.gz" \
      "https://github.com/joshmedeski/sesh/releases/download/v${ver}/sesh_${at}.tar.gz" \
     && run tar -C "$tmp" -xzf "$tmp/sesh.tar.gz"; then
    bin="$(find "$tmp" -type f -name sesh | head -1)"
    [ -n "$bin" ] && run install "$bin" "$LOCALBIN/sesh"; rm -rf "$tmp"; have sesh
  else rm -rf "$tmp"; return 1; fi
}
install_television_release() {
  bold "Installing television from GitHub release"
  local at; case "$ARCH" in
    x86_64|amd64)  at="x86_64-unknown-linux-gnu" ;;
    aarch64|arm64) at="aarch64-unknown-linux-gnu" ;; *) return 1 ;; esac
  local ver tmp bin
  # television tags carry no 'v' prefix (e.g. 0.15.8); the optional v? handles either form.
  ver="$(curl -fsSL https://api.github.com/repos/alexpasmantier/television/releases/latest 2>/dev/null \
        | sed -nE 's/.*"tag_name": *"v?([^"]+)".*/\1/p' | head -1)"
  [ -z "$ver" ] && return 1
  tmp="$(mktemp -d)"
  if run curl -fsSL -o "$tmp/tv.tar.gz" \
      "https://github.com/alexpasmantier/television/releases/download/${ver}/tv-${ver}-${at}.tar.gz" \
     && run tar -C "$tmp" -xzf "$tmp/tv.tar.gz"; then
    bin="$(find "$tmp" -type f -name tv | head -1)"
    [ -n "$bin" ] && run install "$bin" "$LOCALBIN/tv"; rm -rf "$tmp"; have tv
  else rm -rf "$tmp"; return 1; fi
}
install_ghdash_release() {
  bold "Installing gh-dash from GitHub release (standalone binary; the gh extension needs auth)"
  local at; case "$ARCH" in x86_64|amd64) at="linux-amd64" ;; aarch64|arm64) at="linux-arm64" ;; *) return 1 ;; esac
  local ver
  ver="$(curl -fsSL https://api.github.com/repos/dlvhdr/gh-dash/releases/latest 2>/dev/null \
        | sed -nE 's/.*"tag_name": *"(v[^"]+)".*/\1/p' | head -1)"
  [ -z "$ver" ] && return 1
  if run curl -fsSL -o "$LOCALBIN/gh-dash" \
      "https://github.com/dlvhdr/gh-dash/releases/download/${ver}/gh-dash_${ver}_${at}"; then
    run chmod +x "$LOCALBIN/gh-dash"; have gh-dash
  else return 1; fi
}
install_gh_release() {  # fallback for distros without gh in their repos
  bold "Installing gh (GitHub CLI) from GitHub release"
  local at; case "$ARCH" in x86_64|amd64) at="amd64" ;; aarch64|arm64) at="arm64" ;; *) return 1 ;; esac
  local ver tmp bin
  ver="$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest 2>/dev/null \
        | sed -nE 's/.*"tag_name": *"v([^"]+)".*/\1/p' | head -1)"
  [ -z "$ver" ] && return 1
  tmp="$(mktemp -d)"
  if run curl -fsSL -o "$tmp/gh.tar.gz" \
      "https://github.com/cli/cli/releases/download/v${ver}/gh_${ver}_linux_${at}.tar.gz" \
     && run tar -C "$tmp" -xzf "$tmp/gh.tar.gz"; then
    bin="$(find "$tmp" -type f -name gh -path '*/bin/*' | head -1)"
    [ -n "$bin" ] && run install "$bin" "$LOCALBIN/gh"; rm -rf "$tmp"; have gh
  else rm -rf "$tmp"; return 1; fi
}

install_compiler() {
  if have cc || have gcc || have clang; then ok "C compiler (present)"; note_installed "cc"; return 0; fi
  bold "Installing C compiler + make"
  case "$PM" in
    apt)    pkg_install build-essential ;;
    dnf)    pkg_install gcc gcc-c++ make ;;
    pacman) pkg_install base-devel ;;
    zypper) pkg_install gcc make ;;
  esac
  if have cc || have gcc || have clang; then note_installed "cc"; else note_failed "cc"; fi
  return 0
}

install_clipboard() {
  if have wl-copy || have xclip || have xsel; then note_installed "clipboard"; return 0; fi
  bold "Installing clipboard provider (xclip / wl-clipboard)"
  pkg_install xclip wl-clipboard >/dev/null 2>&1 || pkg_install xclip >/dev/null 2>&1 || true
  if have wl-copy || have xclip || have xsel; then note_installed "clipboard"
  else warn "no clipboard tool — nvim/tmux fall back to OSC52 over the terminal"; note_skipped "clipboard"; fi
  return 0
}

# ── one batched distro install (Linux) ──
# The per-tool ess() calls below each cost ~1s of apt startup. Pre-installing the whole
# distro set in ONE call makes every ess() check hit the fast "already present" path
# (~15s saved across the tier); the handful not in the repos (nvim, yazi, lazygit, sesh,
# tv, gh-dash, starship) still go through their release installers. If the batch fails (a
# package name missing on this distro) we retry one-by-one so one absentee can't block it.
prefetch_apt() {
  [ -n "$PM" ] || return 0
  local pk=(curl git stow zsh zsh-autosuggestions zsh-syntax-highlighting tmux fzf ripgrep
            zoxide jq btop file unzip tar gzip eza gh xclip wl-clipboard nodejs npm git-delta)
  case "$PM" in
    apt)    pk+=(build-essential fd-find bat python3 python3-pip python3-venv) ;;
    dnf)    pk+=(gcc gcc-c++ make fd-find bat python3 python3-pip) ;;
    pacman) pk+=(base-devel fd bat python python-pip) ;;
    zypper) pk+=(gcc make fd bat python3 python3-pip) ;;
  esac
  if [ "$NO_MEDIA" = 0 ]; then  # yazi rich previews (image/video/PDF/archive) — gated by --no-media
    case "$PM" in
      apt)    pk+=(imagemagick ffmpeg chafa poppler-utils p7zip-full) ;;
      dnf)    pk+=(ImageMagick ffmpeg chafa poppler-utils p7zip) ;;
      pacman) pk+=(imagemagick ffmpeg chafa poppler 7zip) ;;
      zypper) pk+=(ImageMagick ffmpeg chafa poppler-tools 7zip) ;;
    esac
  else
    info "media-preview tools skipped (--no-media)"
  fi
  bold "Batch-installing ${#pk[@]} distro packages in one call (skips ~1s/pkg of apt overhead)"
  if pkg_install "${pk[@]}"; then ok "batch install complete"
  else
    warn "batch hit an unavailable package — retrying each individually"
    local p; for p in "${pk[@]}"; do pkg_install "$p" >/dev/null 2>&1 || true; done
  fi
}

# record which media-preview tools ended up present (for the summary) — never installs.
note_media() {
  [ "$NO_MEDIA" = 1 ] && return 0
  have magick || have convert     && note_installed "imagemagick" || note_skipped "imagemagick"
  have ffmpeg                      && note_installed "ffmpeg"      || note_skipped "ffmpeg"
  have chafa                       && note_installed "chafa"       || note_skipped "chafa"
  have pdftoppm                    && note_installed "poppler"     || note_skipped "poppler"
  have 7z || have 7za || have 7zz  && note_installed "7zip"        || note_skipped "7zip"
  return 0
}

# ── REQUIRED tier (Linux) — prefetch_apt() did the bulk apt install, so the ess() calls
#    here mostly confirm presence; release installers cover what the repos don't ship. ──
install_essentials_linux() {
  bold "REQUIRED tier"
  if [ -z "$PM" ]; then
    warn "no supported package manager — install curl/git/stow/zsh/tmux/neovim by hand"
    note_failed "essentials (no package manager)"; return
  fi

  ess "curl" curl curl
  ess "git"  git  git
  ess "stow" stow stow
  install_compiler
  ess "zsh" zsh zsh

  FALLBACK_FN=fallback_starship; ess "starship" starship starship
  ess "tmux" tmux tmux
  ess "fzf"  fzf  fzf
  ess "ripgrep" rg ripgrep
  ess "zoxide"  zoxide zoxide
  ess "jq"   jq   jq
  ess "btop" btop btop

  case "$PM" in apt|dnf) ess "fd" fd fd-find ;; *) ess "fd" fd fd ;; esac
  ess "bat" bat bat
  make_shim fd fdfind
  make_shim bat batcat

  case "$PM" in apt) FALLBACK_FN=install_eza_fallback ;; esac
  ess "eza" eza eza
  ess "node" node nodejs
  if have python3 || have python; then note_installed "python"; else warn "python missing"; note_failed "python"; fi

  install_clipboard
  # `file` (libmagic): yazi shells out to it for MIME detection — without it previews error.
  ess "file" file file

  # GitHub CLI + dashboard. gh is in current distro repos (release fallback for older ones);
  # gh-dash ships only as a standalone binary — the `gh extension` route needs auth.
  FALLBACK_FN=install_gh_release; ess "gh" gh gh
  have gh-dash || { install_ghdash_release && note_installed "gh-dash (release)" || note_skipped "gh-dash"; }

  # yazi: the nvim file explorer (<leader>e) — neo-tree is disabled, no fallback tree.
  case "$PM" in
    pacman) ess "yazi" yazi yazi ;;
    *)      FALLBACK_FN=install_yazi_fallback; ess "yazi" yazi yazi ;;
  esac

  # lazygit (<leader>gg, yazi Ctrl-G); git-delta is lazygit's pager.
  case "$PM" in
    apt|zypper|dnf) FALLBACK_FN=install_lazygit_release; ess "lazygit" lazygit lazygit ;;
    pacman)         ess "lazygit" lazygit lazygit ;;
  esac
  case "$PM" in
    apt|zypper) FALLBACK_FN=install_delta_release; ess "git-delta" delta git-delta ;;
    dnf|pacman) ess "git-delta" delta git-delta ;;
  esac

  # sesh (prefix s/S) + television (tv; prefix s/w) — not in the repos and we don't assume
  # go/cargo, so install the prebuilt release binaries.
  have sesh || { install_sesh_release       && note_installed "sesh (release)"       || note_failed "sesh"; }
  have tv   || { install_television_release && note_installed "television (release)" || note_failed "television"; }

  note_media
}

# ── macOS ──
install_mac() {
  if ! have brew; then
    warn "Homebrew not found — install it first: https://brew.sh, then re-run."
    warn "Continuing to stow configs only (tools skipped)."; return
  fi
  if [ "$CLI_ONLY" = 1 ]; then
    bold "brew bundle — CLI formulae only (skipping the GUI casks + fonts)"
    # Filter the Brewfile to tap + brew lines: every CLI formula, none of the GUI casks
    # or fonts. Keeps the Brewfile the single source of truth (no second list to drift).
    local tmp; tmp="$(mktemp)"
    grep -E '^(tap|brew) ' Brewfile > "$tmp" 2>/dev/null || true
    run brew bundle --file="$tmp" || warn "brew bundle (CLI) had failures (continuing)"
    rm -f "$tmp"
    note_installed "macOS CLI formulae (no GUI)"
  else
    bold "brew bundle --file=Brewfile (full public set: CLIs + casks + fonts)"
    run brew bundle --file=Brewfile || warn "brew bundle had failures (continuing)"
    note_installed "Brewfile (full)"
  fi
}

# ── delegate stow/hooks/tpm to setup.sh ──
run_setup() {
  bold "Running ./setup.sh (stow + gitleaks hook + tpm)"
  # --minimal stows the CLI packages only (skips the macOS GUI configs: aerospace,
  # karabiner, ghostty, zed). Use it on Linux/WSL always, and on macOS under --cli-only.
  if [ "$OS" = "Darwin" ] && [ "$CLI_ONLY" = 0 ]; then run ./setup.sh; else run ./setup.sh --minimal; fi
}

# ── Linux post-stow fixups (non-destructive: only create new files) ──
post_stow_fixups() {
  [ "$OS" = "Darwin" ] && return 0
  bold "Linux post-stow fixups"
  # lazygit reads ~/.config/lazygit on Linux; the package stows the macOS ~/Library path.
  local lg="$HOME/Library/Application Support/lazygit/config.yml"
  if [ -e "$lg" ] && [ ! -e "$HOME/.config/lazygit/config.yml" ]; then
    run mkdir -p "$HOME/.config/lazygit"
    run ln -sf "$lg" "$HOME/.config/lazygit/config.yml"
    ok "lazygit config linked into ~/.config/lazygit/"
  fi
  # btop kanagawa theme is referenced but not tracked — fetch it (best-effort).
  if [ -d "$HOME/.config/btop" ] && [ ! -f "$HOME/.config/btop/themes/kanagawa.theme" ]; then
    run mkdir -p "$HOME/.config/btop/themes"
    run curl -fsSL -o "$HOME/.config/btop/themes/kanagawa.theme" \
      "https://raw.githubusercontent.com/rebelot/kanagawa.nvim/master/extras/btop/kanagawa.theme" 2>/dev/null \
      && ok "fetched btop kanagawa theme" || warn "btop theme not fetched (default colors)"
  fi
  return 0
}

# ── headless plugin bootstrap ──
bootstrap_plugins() {
  [ "$NO_BOOTSTRAP" = 1 ] && { info "skipping plugin bootstrap (--no-bootstrap)"; return; }
  [ "$DRY_RUN" = 1 ] && { info "[dry-run] nvim Lazy! sync; tpm install_plugins"; return; }
  if have nvim && ! nvim_too_old; then
    bold "Bootstrapping Neovim plugins (Lazy! sync)"
    nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 || warn "nvim Lazy sync had issues (check :Lazy on first launch)"
    ok "Neovim plugins synced"
  else
    warn "nvim missing/too old — skipping plugin bootstrap"
  fi
  if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
    bold "Installing tmux plugins (tpm)"
    "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 || warn "tpm had issues (run prefix+I in tmux)"
    ok "tmux plugins installed"
  fi
}

# ── chsh offer ──
offer_chsh() {
  [ "$DRY_RUN" = 1 ] && return
  have zsh || return
  case "${SHELL:-}" in *zsh) ok "login shell is already zsh"; return ;; esac
  local zp; zp="$(command -v zsh)"
  if [ "$ASSUME_YES" = 1 ]; then
    chsh -s "$zp" 2>/dev/null && ok "login shell set to zsh" || warn "chsh failed — run: chsh -s $zp"
    return
  fi
  printf '\nSet zsh as your login shell? [y/N] '
  read -r ans </dev/tty 2>/dev/null || ans=""
  case "$ans" in
    [yY]*) chsh -s "$zp" 2>/dev/null && ok "login shell set to zsh (re-login to apply)" \
             || warn "chsh failed — run: chsh -s $zp" ;;
    *) info "skipped — run 'chsh -s $zp' later to make zsh your login shell" ;;
  esac
}

print_summary() {
  echo; bold "Summary"
  echo "  OS=$OS  pkg-manager=${PM:-none}  arch=$ARCH"
  [ -n "$INSTALLED" ] && printf '  \033[32mInstalled/present:\033[0m%s\n' "$INSTALLED"
  [ -n "$SKIPPED"   ] && printf '  \033[33mSkipped (best-effort):\033[0m%s\n' "$SKIPPED"
  [ -n "$FAILED"    ] && printf '  \033[31mFailed (required):\033[0m%s\n' "$FAILED"
  cat <<'NOTE'

Manual follow-ups:
  • gh auth login               # GitHub HTTPS credentials (restores ~/.config/gh/hosts.yml)
  • Install a Nerd Font in your terminal (starship/eza/yazi glyphs need one)
  • Optional/opt-in (yazi rich previews): mdterm (cargo), nbpreview (pipx), duckdb
  • In tmux, if plugins didn't auto-install: prefix + I
NOTE
  [ -n "$FAILED" ] && warn "Some required tools failed above — resolve and re-run, or install by hand."
  return 0
}

# ── drop straight into the freshly-configured zsh ──
# chsh only takes effect on the NEXT login, and the tools/prompt live behind zsh's
# .zprofile/.zshrc — so exec a login zsh now to make everything live in this session.
launch_shell() {
  [ "$DRY_RUN" = 1 ] && return
  have zsh || return
  [ -t 0 ] && [ -t 1 ] || return            # interactive only — never hijack a piped/CI run
  case "${SHELL:-}" in *zsh) return ;; esac  # already a zsh login shell — nothing to switch to
  bold "Starting zsh so your prompt + tools are live now (exit / Ctrl-D to leave)"
  exec zsh -l
}

main() {
  bold "dotfiles cross-platform installer"
  echo "  Detected: OS=$OS  pkg-manager=${PM:-none}  arch=$ARCH  sudo='${SUDO:-none}'"
  [ "$DRY_RUN" = 1 ] && info "DRY RUN — nothing will execute"
  echo

  if [ "$OS" = "Darwin" ]; then
    install_mac
  elif [ -z "$PM" ]; then
    warn "Unsupported Linux without apt/dnf/pacman/zypper — install tools by hand; stowing configs only."
  else
    prefetch_apt              # one batched distro install (incl. media unless --no-media)
    install_neovim
    install_essentials_linux
  fi

  run_setup
  post_stow_fixups
  bootstrap_plugins
  offer_chsh
  print_summary
  launch_shell   # interactive runs end inside a live zsh; piped/CI runs return to the caller
}

main "$@"
