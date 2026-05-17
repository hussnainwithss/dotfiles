#!/usr/bin/env bash
# runtimes.sh — language version managers & runtimes (macOS + Linux)
set -euo pipefail

log()  { echo ""; echo "==> $*"; }
have() { command -v "$1" &>/dev/null; }

# ── Node.js via nvm ───────────────────────────────────────────────────────────
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if [[ ! -d "$NVM_DIR" ]]; then
  log "Installing nvm"
  NVM_VERSION=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep -oP '"tag_name": "\K[^"]+')
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
fi

# Load nvm in this script session
# shellcheck source=/dev/null
source "$NVM_DIR/nvm.sh"

log "Installing Node.js LTS"
nvm install --lts
nvm alias default 'lts/*'

log "Installing global Node packages"
npm install -g pnpm yarn typescript ts-node

# ── Python via uv + pyenv ─────────────────────────────────────────────────────
if ! have uv; then
  log "Installing uv (Python package manager)"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

if ! have pyenv; then
  log "Installing pyenv"
  curl -fsSL https://pyenv.run | bash
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path 2>/dev/null || true)"
eval "$(pyenv init - 2>/dev/null || true)"

PYTHON_VERSION="3.12"
if ! pyenv versions | grep -q "$PYTHON_VERSION"; then
  log "Installing Python $PYTHON_VERSION via pyenv"
  pyenv install "$PYTHON_VERSION"
  pyenv global "$PYTHON_VERSION"
fi

log "Installing common Python packages"
uv pip install --system \
  ipython jupyterlab \
  numpy pandas matplotlib seaborn scikit-learn \
  httpx fastapi uvicorn \
  ruff black mypy \
  boto3 google-cloud-storage azure-storage-blob \
  2>/dev/null || true

# ── Go ────────────────────────────────────────────────────────────────────────
if ! have go; then
  log "Installing Go"
  GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -1)
  OS=$(uname -s | tr '[:upper:]' '[:lower:]')
  ARCH=$(uname -m)
  [[ "$ARCH" == "x86_64" ]] && ARCH="amd64"
  [[ "$ARCH" == "aarch64" ]] && ARCH="arm64"
  curl -Lo /tmp/go.tar.gz "https://dl.google.com/go/${GO_VERSION}.${OS}-${ARCH}.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf /tmp/go.tar.gz
  rm /tmp/go.tar.gz
  export PATH="/usr/local/go/bin:$PATH"
fi

log "Installing common Go tools"
go install golang.org/x/tools/gopls@latest          2>/dev/null || true
go install github.com/air-verse/air@latest           2>/dev/null || true  # live reload
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest 2>/dev/null || true

# ── Rust via rustup ───────────────────────────────────────────────────────────
if ! have rustup; then
  log "Installing Rust via rustup"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi

# shellcheck source=/dev/null
source "$HOME/.cargo/env" 2>/dev/null || export PATH="$HOME/.cargo/bin:$PATH"

log "Updating Rust toolchain"
rustup update stable
rustup component add clippy rustfmt

log "Installing common Rust CLI tools"
cargo install cargo-watch cargo-edit cargo-nextest 2>/dev/null || true
