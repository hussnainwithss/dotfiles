# dotfiles

Cross-platform machine bootstrap — macOS, Linux, Windows.

## Quick start

### macOS / Linux

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
bash ~/dotfiles/bootstrap.sh
```

### Windows (PowerShell as Administrator)

```powershell
git clone https://github.com/YOUR_USERNAME/dotfiles.git $HOME\dotfiles
$HOME\dotfiles\bootstrap.ps1
```

---

## What gets installed

| Category | Tools |
|---|---|
| Shell | **fish** (default), zsh, starship prompt, zoxide, fzf, direnv |
| Terminal | **Ghostty** — Catppuccin Mocha theme, Fira Code Nerd Font |
| Multiplexer | **tmux** — Ctrl-a prefix, vim keys, auto-save sessions |
| CLI | git, gh, ripgrep, fd, bat, eza, jq, yq, neovim, htop, make, tree |
| Node.js | nvm → Node LTS, pnpm, yarn, typescript, ts-node |
| Python | pyenv → 3.12, uv, ipython, jupyterlab, numpy, pandas, scikit-learn, ruff |
| Go | latest stable + gopls, air, golangci-lint |
| Rust | rustup → stable, clippy, rustfmt, cargo-watch |
| Containers | Docker, docker-compose |
| Kubernetes | kubectl, helm, k9s, minikube, krew |
| IaC | Terraform, Pulumi |
| Cloud | AWS CLI v2, Google Cloud SDK, Azure CLI |
| Task runner | Taskfile (`task`), make |
| DB clients | PostgreSQL client, Redis CLI |
| GUI (macOS) | VS Code, Docker Desktop, Postman, TablePlus |

---

## Flags

### macOS / Linux

| Flag | What it skips |
|---|---|
| `--no-casks` | GUI apps (good for servers / CI) |
| `--skip-runtimes` | Node, Python, Go, Rust |
| `--skip-devops` | kubectl, helm, Terraform, cloud CLIs |

```bash
# Server / headless machine
bash ~/dotfiles/bootstrap.sh --no-casks --skip-devops

# Already have runtimes, just want DevOps tools
bash ~/dotfiles/bootstrap.sh --skip-runtimes
```

### Windows

```powershell
.\bootstrap.ps1 -NoGui -SkipRuntimes -SkipDevOps
```

---

## After bootstrap

### tmux — install plugins

First time you open tmux, press:

```
Ctrl-a  then  Shift-I
```

This installs TPM plugins (resurrect, continuum, yank, vim-navigator). Takes ~10 seconds.

**Key bindings:**

| Keys | Action |
|---|---|
| `Ctrl-a \|` | Split pane horizontal |
| `Ctrl-a -` | Split pane vertical |
| `Ctrl-a h/j/k/l` | Move between panes |
| `Ctrl-a c` | New window |
| `Ctrl-a r` | Reload tmux config |
| `Ctrl-a Enter` | Enter copy mode (vi keys) |

Sessions survive reboot automatically (tmux-continuum).

### fish — plugins already installed

Fisher and plugins install automatically during bootstrap. To update later:

```fish
fisher update
```

Plugins included: `fzf.fish` (Ctrl-R history, Ctrl-F files), `nvm.fish`, `done` (notify on long commands), `puffer-fish`, `z` (jump to dirs).

### Ghostty — font

Fira Code Nerd Font is installed automatically. If icons look broken, confirm the font installed:

```bash
fc-list | grep "Fira"          # Linux
brew list font-fira-code-nerd-font  # macOS
```

---

## Configs

All configs live in `~/dotfiles/config/` and are **symlinked** to `~/.config/` — edit them in the repo, changes apply immediately.

| File | Linked to |
|---|---|
| `config/fish/config.fish` | `~/.config/fish/config.fish` |
| `config/ghostty/config` | `~/.config/ghostty/config` |
| `config/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` |

Re-run symlinks anytime:

```bash
bash ~/dotfiles/scripts/link_configs.sh
```

---

## Adding packages

| Platform | File | Apply |
|---|---|---|
| macOS | `packages/Brewfile` | `brew bundle --file=packages/Brewfile` |
| Linux | `scripts/linux.sh` | re-run the script |
| Windows | `scripts/windows/packages.ps1` | re-run the script |

---

## File structure

```
dotfiles/
├── bootstrap.sh                  # macOS + Linux entry point
├── bootstrap.ps1                 # Windows entry point
├── config/
│   ├── fish/
│   │   ├── config.fish           # aliases, PATH, completions
│   │   └── fish_plugins          # fisher plugin list
│   ├── ghostty/
│   │   └── config                # theme, font, keybinds
│   └── tmux/
│       └── tmux.conf             # full tmux config + TPM plugins
├── packages/
│   └── Brewfile                  # all macOS homebrew packages
└── scripts/
    ├── macos.sh                  # Homebrew + Brewfile + set fish default
    ├── linux.sh                  # apt/dnf/pacman + Docker + Ghostty
    ├── runtimes.sh               # nvm, pyenv, uv, Go, Rust (Unix)
    ├── devops.sh                 # kubectl, helm, k9s, Terraform, cloud CLIs (Unix)
    ├── link_configs.sh           # symlink config/* → ~/.config/* + fonts + TPM + fisher
    ├── shell_config.sh           # append PATH/aliases to .zshrc/.bashrc (zsh fallback)
    └── windows/
        ├── packages.ps1          # winget + scoop core tools + fish + Ghostty
        ├── runtimes.ps1          # nvm-windows, pyenv-win, uv, Go, Rust
        └── devops.ps1            # kubectl, helm, k9s, Terraform, cloud CLIs
```

---

## Push to GitHub

```bash
cd ~/dotfiles
git remote add origin https://github.com/YOUR_USERNAME/dotfiles.git
git push -u origin main
```

On a new machine:

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles && bash ~/dotfiles/bootstrap.sh
```
