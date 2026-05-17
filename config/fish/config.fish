# config.fish — fish shell config
# Linked to ~/.config/fish/config.fish by install script

# ── PATH ──────────────────────────────────────────────────────────────────────
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin
fish_add_path /usr/local/go/bin
fish_add_path $HOME/go/bin
fish_add_path $HOME/.pyenv/bin
fish_add_path $HOME/.krew/bin

# macOS Homebrew (Apple Silicon)
if test -f /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

# ── nvm (fish via bass or nvm.fish) ──────────────────────────────────────────
# Uses jorgebucaran/nvm.fish — installed via fisher in fish_plugins
set -gx NVM_DIR $HOME/.nvm

# ── pyenv ─────────────────────────────────────────────────────────────────────
if command -q pyenv
    pyenv init - fish | source
end

# ── Google Cloud SDK ──────────────────────────────────────────────────────────
if test -f $HOME/google-cloud-sdk/path.fish.inc
    source $HOME/google-cloud-sdk/path.fish.inc
end

# ── Shell integrations ────────────────────────────────────────────────────────
if command -q starship
    starship init fish | source
end

if command -q zoxide
    zoxide init fish | source
end

if command -q direnv
    direnv hook fish | source
end

# ── Aliases ───────────────────────────────────────────────────────────────────
alias ls  'eza --icons'
alias ll  'eza -lah --icons'
alias lt  'eza --tree --level=2 --icons'
alias cat 'bat --paging=never'
alias vim 'nvim'
alias k   'kubectl'
alias tf  'terraform'
alias dc  'docker compose'

# git
alias gs  'git status'
alias gp  'git pull --rebase'
alias gpr 'git push'
alias gl  'git log --oneline --graph --decorate -20'

# ── kubectl completions ────────────────────────────────────────────────────────
if command -q kubectl
    kubectl completion fish | source
end
if command -q helm
    helm completion fish | source
end
