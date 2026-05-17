#!/usr/bin/env bash
# link_configs.sh — symlink dotfiles/config/* into ~/.config/
# Safe: backs up any existing file before replacing.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_SRC="$DOTFILES_DIR/config"
CONFIG_DST="$HOME/.config"

log()    { echo ""; echo "==> $*"; }
link()   {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    mv "$dst" "${dst}.bak.$(date +%s)"
    echo "  Backed up existing: $dst"
  fi
  ln -sfn "$src" "$dst"
  echo "  Linked: $dst -> $src"
}

log "Linking configs"

# fish
link "$CONFIG_SRC/fish/config.fish"   "$CONFIG_DST/fish/config.fish"
link "$CONFIG_SRC/fish/fish_plugins"  "$CONFIG_DST/fish/fish_plugins"

# ghostty
link "$CONFIG_SRC/ghostty/config"     "$CONFIG_DST/ghostty/config"

# tmux
link "$CONFIG_SRC/tmux/tmux.conf"     "$CONFIG_DST/tmux/tmux.conf"
# also support legacy path
ln -sfn "$CONFIG_DST/tmux/tmux.conf" "$HOME/.tmux.conf" 2>/dev/null || true

log "Installing TPM (tmux plugin manager)"
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

log "Installing Fisher (fish plugin manager)"
if command -v fish &>/dev/null; then
  fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher" 2>/dev/null || true
  fish -c "fisher update" 2>/dev/null || true
fi

log "Nerd Fonts (JetBrainsMono) for Ghostty"
if [[ "$(uname -s)" == "Darwin" ]]; then
  brew tap homebrew/cask-fonts 2>/dev/null || true
  brew install --cask font-jetbrains-mono-nerd-font 2>/dev/null || true
else
  FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"
  if ! fc-list | grep -qi "JetBrainsMono Nerd"; then
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
    curl -Lo /tmp/JetBrainsMono.tar.xz "$FONT_URL"
    tar -xJf /tmp/JetBrainsMono.tar.xz -C "$FONT_DIR"
    fc-cache -f "$FONT_DIR"
    rm /tmp/JetBrainsMono.tar.xz
  fi
fi

echo ""
echo "Configs linked. In tmux, press prefix + I to install plugins."
echo "To set fish as default shell, run: chsh -s \$(which fish)"
