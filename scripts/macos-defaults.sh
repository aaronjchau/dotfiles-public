#!/usr/bin/env bash
# macos-defaults.sh — curated macOS defaults, codified so a fresh machine reproduces them. Idempotent.
#   ./scripts/macos-defaults.sh
# The keyboard/text settings take effect after a logout/restart (apps read them
# at launch); the Dock/Finder changes apply when this script restarts those apps.
# Revert any line with:  defaults delete <domain> <key>   (restores the default)
set -euo pipefail

echo "Applying macOS defaults…"

# ── Keyboard ────────────────────────────────────────────────────────────────
# Hold a key to REPEAT instead of showing the accent popup; fast repeat, short delay.
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g KeyRepeat -int 2          # lower = faster repeat
defaults write -g InitialKeyRepeat -int 15  # lower = shorter delay before repeat

# ── Text input ──────────────────────────────────────────────────────────────
# Kill the "smart" substitutions that mangle code / CLI flags / markdown.
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false  # " stays " (not “ ”)
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false   # -- stays -- (not —)

# ── Dock ────────────────────────────────────────────────────────────────────
defaults write com.apple.dock autohide -bool true                 # auto-hide the Dock
defaults write com.apple.dock autohide-time-modifier -float 0.15  # snappier show/hide animation
defaults write com.apple.dock magnification -bool true            # magnify icons on hover
defaults write com.apple.dock tilesize -int 58                    # resting icon size
defaults write com.apple.dock mru-spaces -bool false              # don't auto-rearrange Spaces (pairs with AeroSpace)
defaults write com.apple.dock wvous-bl-corner -int 4              # bottom-left hot corner → Show Desktop
defaults write com.apple.dock wvous-bl-modifier -int 0            # …no modifier key required

# ── Finder ────────────────────────────────────────────────────────────────────
defaults write com.apple.finder ShowStatusBar -bool true                    # show item count + free space
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"         # default to Column view
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false # no external drives on the desktop
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false     # no USB / removable media on the desktop

echo "Restarting Dock and Finder…"
killall Dock Finder 2>/dev/null || true
echo "Done. The keyboard/text settings need a logout/restart to fully apply."
