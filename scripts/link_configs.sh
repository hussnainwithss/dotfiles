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
ln -sfn "$CONFIG_DST/tmux/tmux.conf" "$HOME/.tmux.conf" 2>/dev/null || true

# git
link "$CONFIG_SRC/git/gitconfig"         "$HOME/.gitconfig"
link "$CONFIG_SRC/git/gitconfig_work"    "$CONFIG_DST/git/gitconfig_work"
link "$CONFIG_SRC/git/gitignore_global"  "$CONFIG_DST/git/gitignore_global"
mkdir -p "$HOME/projects/personal" "$HOME/projects/work"

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

log "Installing Fira Code + Fira Code Nerd Font"
if [[ "$(uname -s)" == "Darwin" ]]; then
  brew install --cask font-fira-code font-fira-code-nerd-font 2>/dev/null || true
else
  FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"
  if ! fc-list | grep -qi "Fira Code"; then
    curl -Lo /tmp/FiraCode.tar.xz \
      "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.tar.xz"
    tar -xJf /tmp/FiraCode.tar.xz -C "$FONT_DIR"
    fc-cache -f "$FONT_DIR"
    rm /tmp/FiraCode.tar.xz
  fi
fi

echo ""
echo "Configs linked. In tmux, press prefix + I to install plugins."
echo "To set fish as default shell, run: chsh -s \$(which fish)"
