#!/usr/bin/env bash
# macOS setup: Homebrew + Brewfile + shell config
set -euo pipefail

log() { echo ""; echo "==> $*"; }

# ── Xcode CLI tools ────────────────────────────────────────────────────────────
if ! xcode-select -p &>/dev/null; then
  log "Installing Xcode Command Line Tools"
  xcode-select --install
  echo "Re-run bootstrap after Xcode CLI tools finish installing."
  exit 0
fi

# ── Homebrew ───────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for Apple Silicon
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

log "Updating Homebrew"
brew update --quiet

# ── Brewfile ───────────────────────────────────────────────────────────────────
log "Installing packages from Brewfile"
BREWFILE="$DOTFILES_DIR/packages/Brewfile"

if [[ "$NO_CASKS" == true ]]; then
  # Headless / work machine: skip GUI casks
  grep -v '^cask ' "$BREWFILE" | brew bundle --file=-
else
  brew bundle --file="$BREWFILE"
fi

# ── Default shell: fish ────────────────────────────────────────────────────────
FISH_PATH="$(brew --prefix)/bin/fish"
if [[ "$SHELL" != "$FISH_PATH" ]]; then
  log "Setting fish as default shell"
  grep -qxF "$FISH_PATH" /etc/shells || sudo sh -c "echo '$FISH_PATH' >> /etc/shells"
  chsh -s "$FISH_PATH"
fi
