# ── Secrets ──
# API tokens are injected per-launch by the claude() wrapper in .zshrc (1Password
# "Your Dev Environment" env). Nothing secret is stored on disk.

[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# UTF-8 locale (needed by some terminal clients)
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# ── gws (Google Workspace CLI): file-based credential storage ──
# Use file creds (~/.config/gws*/credentials.json) not the Keychain: the Keychain
# backend is unreadable in non-GUI shells and can destructively delete creds.
export GOOGLE_WORKSPACE_CLI_KEYRING_BACKEND=file
