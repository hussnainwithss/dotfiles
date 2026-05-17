#!/usr/bin/env bash
# Linux setup: detect distro, install base packages, then common tools
set -euo pipefail

log()  { echo ""; echo "==> $*"; }
have() { command -v "$1" &>/dev/null; }

# ── Detect distro ──────────────────────────────────────────────────────────────
if [[ -f /etc/os-release ]]; then
  # shellcheck source=/dev/null
  source /etc/os-release
  DISTRO="${ID:-unknown}"
else
  DISTRO="unknown"
fi

log "Distro: $DISTRO"

install_apt() {
  sudo apt-get update -qq
  sudo apt-get install -y \
    git curl wget unzip tar gzip \
    zsh fish build-essential pkg-config \
    jq fzf ripgrep fd-find bat \
    tmux neovim htop tree direnv \
    make ca-certificates gnupg lsb-release \
    postgresql-client redis-tools \
    python3-pip python3-venv libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev libffi-dev \
    libncursesw5-dev xz-utils tk-dev liblzma-dev

  # fd and bat have different binary names on Debian/Ubuntu
  [[ -f /usr/bin/fdfind ]]  && sudo ln -sf /usr/bin/fdfind  /usr/local/bin/fd  2>/dev/null || true
  [[ -f /usr/bin/batcat ]]  && sudo ln -sf /usr/bin/batcat   /usr/local/bin/bat 2>/dev/null || true
}

install_dnf() {
  sudo dnf install -y \
    git curl wget unzip tar gzip \
    zsh gcc gcc-c++ make pkg-config \
    jq fzf ripgrep fd-find bat \
    tmux neovim htop tree direnv \
    ca-certificates gnupg \
    postgresql redis \
    python3-pip python3-devel openssl-devel bzip2-devel \
    libffi-devel readline-devel sqlite-devel \
    ncurses-devel xz-devel
}

case "$DISTRO" in
  ubuntu|debian|linuxmint|pop)
    log "Using apt"
    install_apt
    ;;
  fedora|rhel|centos|rocky|alma)
    log "Using dnf"
    install_dnf
    ;;
  arch|manjaro|endeavouros)
    log "Using pacman"
    sudo pacman -Syu --noconfirm \
      git curl wget unzip tar gzip zsh base-devel \
      jq fzf ripgrep fd bat tmux neovim htop tree direnv make \
      postgresql redis python-pip openssl
    ;;
  *)
    log "Unknown distro '$DISTRO' — skipping OS package install. Install deps manually."
    ;;
esac

# ── Docker Engine (Linux) ─────────────────────────────────────────────────────
if ! have docker; then
  log "Installing Docker Engine"
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$USER"
  log "Docker installed. Log out and back in for group membership to take effect."
fi

# ── Starship prompt ────────────────────────────────────────────────────────────
if ! have starship; then
  log "Installing Starship prompt"
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# ── eza (modern ls) ────────────────────────────────────────────────────────────
if ! have eza; then
  log "Installing eza"
  EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | jq -r '.tag_name')
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64)  EZA_ARCH="x86_64-unknown-linux-musl" ;;
    aarch64) EZA_ARCH="aarch64-unknown-linux-musl" ;;
    *)       log "eza: unsupported arch $ARCH, skipping"; EZA_ARCH="" ;;
  esac
  if [[ -n "$EZA_ARCH" ]]; then
    curl -Lo /tmp/eza.tar.gz \
      "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_${EZA_ARCH}.tar.gz"
    tar -xzf /tmp/eza.tar.gz -C /tmp
    sudo mv /tmp/eza /usr/local/bin/eza
  fi
fi

# ── zoxide ────────────────────────────────────────────────────────────────────
if ! have zoxide; then
  log "Installing zoxide"
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# ── Ghostty (Linux AppImage) ──────────────────────────────────────────────────
if ! have ghostty; then
  log "Installing Ghostty"
  GHOSTTY_VERSION=$(curl -s https://api.github.com/repos/ghostty-org/ghostty/releases/latest | jq -r '.tag_name')
  ARCH=$(uname -m)
  [[ "$ARCH" == "x86_64" ]] && G_ARCH="x86_64" || G_ARCH="aarch64"
  curl -Lo /tmp/ghostty.tar.gz \
    "https://github.com/ghostty-org/ghostty/releases/download/${GHOSTTY_VERSION}/ghostty-linux-${G_ARCH}.tar.gz" 2>/dev/null \
    || log "Ghostty release not found for this arch — install manually from https://ghostty.org"
  [[ -f /tmp/ghostty.tar.gz ]] && {
    tar -xzf /tmp/ghostty.tar.gz -C /tmp
    sudo mv /tmp/ghostty /usr/local/bin/ghostty 2>/dev/null || true
    rm /tmp/ghostty.tar.gz
  }
fi

# ── Default shell: fish ───────────────────────────────────────────────────────
if have fish && [[ "$SHELL" != "$(which fish)" ]]; then
  log "Setting fish as default shell"
  grep -qxF "$(which fish)" /etc/shells || sudo sh -c "echo '$(which fish)' >> /etc/shells"
  chsh -s "$(which fish)"
fi
