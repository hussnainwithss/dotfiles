# dotfiles

Cross-platform machine bootstrap — macOS, Linux (Ubuntu/Debian/Fedora/Arch), Windows.

## What gets installed

| Category | Tools |
|---|---|
| Shell | fish (default), zsh, starship, zoxide, fzf, direnv |
| Terminal | Ghostty (GPU-accelerated, JetBrainsMono Nerd Font, Catppuccin theme) |
| Multiplexer | tmux (Ctrl-a prefix, vim keys, TPM plugins, Catppuccin status bar) |
| CLI | git, gh, ripgrep, fd, bat, eza, jq, yq, tmux, neovim, htop, make |
| Node.js | nvm → Node LTS, pnpm, yarn, typescript, ts-node |
| Python | pyenv → Python 3.12, uv, ipython, jupyterlab, numpy, pandas, scikit-learn, ruff |
| Go | latest stable + gopls, air, golangci-lint |
| Rust | rustup → stable + clippy, rustfmt, cargo-watch |
| Containers | Docker, docker-compose |
| Kubernetes | kubectl, helm, k9s, minikube, krew |
| IaC | Terraform, Pulumi |
| Cloud CLIs | AWS CLI v2, Google Cloud SDK, Azure CLI |
| Task runner | Taskfile (`task`) |
| DB clients | PostgreSQL client, Redis CLI |
| GUI (optional) | VS Code, Docker Desktop, Postman, TablePlus/iTerm2 |

## Usage

### macOS / Linux

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash bootstrap.sh
```

**Flags:**

| Flag | Effect |
|---|---|
| `--no-casks` | Skip GUI apps (good for servers/CI) |
| `--skip-runtimes` | Skip Node/Python/Go/Rust install |
| `--skip-devops` | Skip K8s/cloud/IaC tools |

### Windows

```powershell
# Run PowerShell as Administrator
git clone https://github.com/YOUR_USERNAME/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles
.\bootstrap.ps1
```

**Flags:** `-NoGui`, `-SkipRuntimes`, `-SkipDevOps`

## Config files

Configs live in `config/` and are symlinked into `~/.config/` by `link_configs.sh` (runs automatically at end of bootstrap):

| File | Destination |
|---|---|
| `config/fish/config.fish` | `~/.config/fish/config.fish` |
| `config/ghostty/config` | `~/.config/ghostty/config` |
| `config/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` |

**After first tmux launch:** press `Ctrl-a I` to install TPM plugins.

**Fish plugins** (via fisher): `fzf.fish`, `nvm.fish`, `done`, `puffer-fish`, `z`

## Adding packages

- **macOS**: add to [`packages/Brewfile`](packages/Brewfile) → `brew bundle --file=packages/Brewfile`
- **Linux**: add to [`scripts/linux.sh`](scripts/linux.sh)
- **Windows**: add to [`scripts/windows/packages.ps1`](scripts/windows/packages.ps1)

## Structure

```
dotfiles/
├── bootstrap.sh              # macOS + Linux entry point
├── bootstrap.ps1             # Windows entry point
├── packages/
│   └── Brewfile              # macOS: all homebrew packages
└── scripts/
    ├── macos.sh              # Homebrew setup
    ├── linux.sh              # apt/dnf/pacman + Docker
    ├── runtimes.sh           # nvm, pyenv, Go, Rust (Unix)
    ├── devops.sh             # K8s, cloud CLIs, IaC (Unix)
    ├── shell_config.sh       # ~/.zshrc / ~/.bashrc aliases & PATH
    └── windows/
        ├── packages.ps1      # winget + scoop
        ├── runtimes.ps1      # Node, Python, Go, Rust
        └── devops.ps1        # K8s, cloud CLIs, IaC
```
