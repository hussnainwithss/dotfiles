#!/usr/bin/env bash
# shell_config.sh — write shared shell aliases/exports to ~/.zshrc / ~/.bashrc
# Idempotent: checks for marker before appending.
set -euo pipefail

MARKER="# dotfiles managed block"

append_if_missing() {
  local file="$1"
  local content="$2"
  if ! grep -qF "$MARKER" "$file" 2>/dev/null; then
    printf '\n%s\n%s\n' "$MARKER" "$content" >> "$file"
    echo "  Updated $file"
  fi
}

CONFIG=$(cat <<'SHELLCONFIG'
# ── PATH additions ─────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/go/bin:$PATH"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# ── nvm ────────────────────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# ── pyenv ─────────────────────────────────────────────────────────────────────
eval "$(pyenv init --path 2>/dev/null || true)"
eval "$(pyenv init - 2>/dev/null || true)"

# ── Google Cloud SDK ──────────────────────────────────────────────────────────
[ -f "$HOME/google-cloud-sdk/path.bash.inc" ]       && source "$HOME/google-cloud-sdk/path.bash.inc"
[ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]  && source "$HOME/google-cloud-sdk/completion.bash.inc"

# ── Shell tools ────────────────────────────────────────────────────────────────
eval "$(starship init zsh 2>/dev/null || starship init bash 2>/dev/null || true)"
eval "$(zoxide init zsh  2>/dev/null || zoxide init bash  2>/dev/null || true)"
eval "$(direnv hook zsh  2>/dev/null || direnv hook bash  2>/dev/null || true)"

# ── Aliases ────────────────────────────────────────────────────────────────────
alias ls='eza --icons'
alias ll='eza -lah --icons'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never'
alias grep='rg'
alias find='fd'
alias vim='nvim'
alias k='kubectl'
alias tf='terraform'
alias dc='docker compose'

# ── Git shortcuts ─────────────────────────────────────────────────────────────
alias gs='git status'
alias gp='git pull --rebase'
alias gpr='git push'
alias gl='git log --oneline --graph --decorate -20'

# ── kubectl completions ────────────────────────────────────────────────────────
command -v kubectl &>/dev/null && source <(kubectl completion zsh 2>/dev/null || kubectl completion bash 2>/dev/null || true)
command -v helm    &>/dev/null && source <(helm completion    zsh 2>/dev/null || helm completion    bash 2>/dev/null || true)
SHELLCONFIG
)

# Apply to zsh and bash
[[ -f "$HOME/.zshrc" ]]  && append_if_missing "$HOME/.zshrc"  "$CONFIG"
[[ -f "$HOME/.bashrc" ]] && append_if_missing "$HOME/.bashrc" "$CONFIG"

# Create ~/.zshrc if it doesn't exist
if [[ ! -f "$HOME/.zshrc" ]]; then
  touch "$HOME/.zshrc"
  append_if_missing "$HOME/.zshrc" "$CONFIG"
fi

echo "Shell config applied."
