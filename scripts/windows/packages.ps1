# packages.ps1 — Core CLI tools via winget + scoop
param([switch]$NoGui)

function Log($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Have($cmd) { $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue) }

function Winget-Install($id, $name) {
  if (-not (winget list --id $id -e --accept-source-agreements 2>$null | Select-String $id)) {
    Log "Installing $name"
    winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements
  } else {
    Write-Host "  $name already installed"
  }
}

function Scoop-Install($pkg) {
  if (-not (scoop list $pkg 2>$null | Select-String $pkg)) {
    scoop install $pkg
  } else {
    Write-Host "  $pkg already installed"
  }
}

# ── Scoop buckets ──────────────────────────────────────────────────────────────
Log "Adding Scoop buckets"
scoop bucket add extras   2>$null | Out-Null
scoop bucket add main     2>$null | Out-Null
scoop bucket add versions 2>$null | Out-Null

# ── Core CLI (winget) ─────────────────────────────────────────────────────────
Log "Installing core CLI tools"
Winget-Install "Git.Git"           "Git"
Winget-Install "GitHub.cli"        "GitHub CLI"
Winget-Install "jqlang.jq"         "jq"
Winget-Install "sharkdp.bat"       "bat"
Winget-Install "sharkdp.fd"        "fd"
Winget-Install "BurntSushi.ripgrep.MSVC" "ripgrep"
Winget-Install "junegunn.fzf"      "fzf"
Winget-Install "Neovim.Neovim"     "Neovim"
Winget-Install "Starship.Starship" "Starship"
Winget-Install "eza-community.eza" "eza"
Winget-Install "ajeetdsouza.zoxide" "zoxide"
Winget-Install "GnuWin32.Make"     "make"

# ── Scoop extras (not on winget or better via scoop) ─────────────────────────
Log "Installing via Scoop"
Scoop-Install "yq"
Scoop-Install "direnv"
Scoop-Install "starship"

# ── Fish shell ────────────────────────────────────────────────────────────────
Log "Installing fish shell"
Scoop-Install "fish"

# ── GUI Apps (skipped with -NoGui for headless/server setups) ─────────────────
if (-not $NoGui) {
  Log "Installing GUI applications"
  Winget-Install "Microsoft.VisualStudioCode"  "VS Code"
  Winget-Install "Docker.DockerDesktop"        "Docker Desktop"
  Winget-Install "Postman.Postman"             "Postman"
  Winget-Install "Microsoft.WindowsTerminal"   "Windows Terminal"
  Winget-Install "ghostty.ghostty"             "Ghostty"
}

# ── Refresh PATH in current session ───────────────────────────────────────────
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")
