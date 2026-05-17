#!/usr/bin/env bash
# bootstrap.sh — entry point for macOS and Linux
# Usage: bash bootstrap.sh [--no-casks] [--skip-runtimes] [--skip-devops]
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NO_CASKS=false
SKIP_RUNTIMES=false
SKIP_DEVOPS=false

for arg in "$@"; do
  case $arg in
    --no-casks)      NO_CASKS=true ;;
    --skip-runtimes) SKIP_RUNTIMES=true ;;
    --skip-devops)   SKIP_DEVOPS=true ;;
  esac
done

export DOTFILES_DIR NO_CASKS

log()  { echo ""; echo "==> $*"; }
die()  { echo "ERROR: $*" >&2; exit 1; }

OS="$(uname -s)"

case "$OS" in
  Darwin)
    log "macOS detected"
    bash "$DOTFILES_DIR/scripts/macos.sh"
    ;;
  Linux)
    log "Linux detected"
    bash "$DOTFILES_DIR/scripts/linux.sh"
    ;;
  *)
    die "Unsupported OS: $OS. Run bootstrap.ps1 on Windows."
    ;;
esac

if [[ "$SKIP_RUNTIMES" == false ]]; then
  log "Installing language runtimes"
  bash "$DOTFILES_DIR/scripts/runtimes.sh"
fi

if [[ "$SKIP_DEVOPS" == false ]]; then
  log "Installing DevOps / cloud tools"
  bash "$DOTFILES_DIR/scripts/devops.sh"
fi

log "Linking configs and installing shell plugins"
bash "$DOTFILES_DIR/scripts/link_configs.sh"

echo ""
echo "Bootstrap complete."
echo "  • Restart your shell or open Ghostty"
echo "  • In tmux, press prefix + I (Ctrl-a I) to install plugins"
echo "  • To make fish your default: chsh -s \$(which fish)"
