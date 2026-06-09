# ── History ──
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt share_history        # share history across concurrent shells
setopt hist_ignore_all_dups # collapse duplicate commands
setopt hist_ignore_space    # don't record commands typed with a leading space
setopt hist_verify          # let me edit a !-history expansion before it runs
setopt inc_append_history   # write commands as they run, not only on exit
setopt extended_history     # record timestamps

# ── Sane shell options ──
setopt auto_cd              # `foo` ⇒ `cd foo` when foo is a directory
setopt interactive_comments # allow #comments at the interactive prompt
unsetopt beep

# ── git aliases ──
alias g='git'
alias gst='git status'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gca='git commit -v --amend'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gds='git diff --staged'
alias glog='git log --oneline --decorate --graph'

export PATH="/opt/homebrew/bin:$PATH"

# Added by LM Studio CLI
export PATH="$PATH:$HOME/.lmstudio/bin"

# GWS CLI multi-account aliases
alias gws-primary='GOOGLE_WORKSPACE_CLI_CONFIG_DIR=~/.config/gws gws'
alias gws-secondary='GOOGLE_WORKSPACE_CLI_CONFIG_DIR=~/.config/gws-secondary gws'
alias gws-tertiary='GOOGLE_WORKSPACE_CLI_CONFIG_DIR=~/.config/gws-tertiary gws'

# Added by pipx
export PATH="$PATH:$HOME/.local/bin"

# Claude Code fullscreen rendering (flicker-free)
export CLAUDE_CODE_NO_FLICKER=1

# vim mode
bindkey -v
# KEYTIMEOUT=20 (200ms) lets `jj` catch the second j; tradeoff: physical Esc lags ~200ms.
export KEYTIMEOUT=20
bindkey -M viins 'jj' vi-cmd-mode   # `jj` leaves insert mode (vi-mode only)

# completion menu
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# source the first readable file that exists (handles brew vs distro plugin paths)
_src_first() { local f; for f in "$@"; do [[ -r "$f" ]] && { source "$f"; return; }; done; }

# autosuggestions (ghost text)
_src_first \
  "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# starship prompt
command -v starship >/dev/null && eval "$(starship init zsh)"

# fzf — fuzzy finder (cd ** <Tab>, Ctrl-T, Ctrl-R). New fzf emits its integration
# via `--zsh`; older distro packages ship keybinding files under /usr/share instead.
if command -v fzf >/dev/null; then
  _fzf=$(fzf --zsh 2>/dev/null)
  if [[ -n "$_fzf" ]]; then
    eval "$_fzf"
  else
    _src_first /usr/share/doc/fzf/examples/key-bindings.zsh /usr/share/fzf/key-bindings.zsh /usr/share/fzf/shell/key-bindings.zsh
    _src_first /usr/share/doc/fzf/examples/completion.zsh /usr/share/fzf/completion.zsh /usr/share/fzf/shell/completion.zsh
  fi
  unset _fzf
fi

# fd — cleaner fzf listings (respects .gitignore, skips junk)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'

# eza — better ls with icons (ll = detailed, including hidden files)
alias ls="eza --icons"
alias ll="eza -la --icons"

# sesh / television session shortcuts
alias ts='tv sesh'            # session picker (sessions-first); same as tmux prefix+s
alias sclone='sesh clone'     # clone a git repo and open a tmux session for it: sclone <url>

# default editor for git commits etc. (yazi opens nvim via its own opener)
export EDITOR="zed --add"

# --mouse: wheel-scroll in less; tradeoff: drag-to-select scrolls (use Shift-drag).
export LESS="-R --mouse"

# ── Keep SSH_CONNECTION honest across tmux re-attaches ──
# A pane keeps stale SSH_CONNECTION after a client detaches, so a local pane looks
# remote (yazi assumes a slow link). Re-sync from tmux's session env each prompt.
if [[ -n "$TMUX" ]]; then
  _tmux_sync_ssh_env() {
    local line
    while IFS= read -r line; do
      case "$line" in
        SSH_CONNECTION=*|SSH_CLIENT=*|SSH_TTY=*) export "$line" ;;
        -SSH_CONNECTION|-SSH_CLIENT|-SSH_TTY)    unset "${line#-}" ;;
      esac
    done < <(tmux show-environment 2>/dev/null)
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _tmux_sync_ssh_env
fi

# zoxide — frecency-based cd (powers yazi's z/Z jump + tmux sessionx)
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# `y` runs yazi and cd's the shell into its last dir on quit (--cwd-file).
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  command rm -f -- "$tmp"
}

# syntax highlighting — MUST be last
_src_first \
  "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Launch Claude Code with the 1Password "Your Dev Environment" env loaded into a subshell.
# Do NOT wrap in `op run` — it forces non-interactive --print mode. Falls back to
# plain claude if op-beta is unavailable.
claude() {
  emulate -L zsh
  if [[ -x "$HOME/.local/bin/op-beta" ]]; then
    (
      while IFS= read -r line; do
        [[ "$line" == *=* ]] && export "$line"
      done < <(OP_SERVICE_ACCOUNT_TOKEN="$(security find-generic-password -s YOUR_OP_KEYCHAIN_ITEM -w 2>/dev/null)" "$HOME/.local/bin/op-beta" environment read YOUR_1PASSWORD_ENV_ID 2>/dev/null)
      command claude "$@"
    )
  else
    command claude "$@"
  fi
}
