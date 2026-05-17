# runtimes.ps1 — Node, Python, Go, Rust on Windows
function Log($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Have($cmd) { $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue) }

function Winget-Install($id, $name) {
  if (-not (winget list --id $id -e 2>$null | Select-String $id)) {
    Log "Installing $name"
    winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements
  }
}

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

# ── Node.js via nvm-windows ───────────────────────────────────────────────────
if (-not (Have nvm)) {
  Log "Installing nvm-windows"
  Winget-Install "CoreyButler.NVMforWindows" "nvm for Windows"
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
              [System.Environment]::GetEnvironmentVariable("Path", "User")
}

if (Have nvm) {
  Log "Installing Node.js LTS"
  nvm install lts
  nvm use lts

  Log "Installing global Node packages"
  npm install -g pnpm yarn typescript ts-node
}

# ── Python via pyenv-win ──────────────────────────────────────────────────────
if (-not (Have pyenv)) {
  Log "Installing pyenv-win"
  Winget-Install "pyenv-win.pyenv-win" "pyenv-win"
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
              [System.Environment]::GetEnvironmentVariable("Path", "User")
}

if (Have pyenv) {
  Log "Installing Python 3.12"
  pyenv install 3.12 --skip-existing
  pyenv global 3.12
}

# ── uv (fast Python package manager) ─────────────────────────────────────────
if (-not (Have uv)) {
  Log "Installing uv"
  Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
}

if (Have uv) {
  Log "Installing common Python packages"
  uv pip install --system ipython jupyterlab numpy pandas matplotlib scikit-learn `
    httpx fastapi uvicorn ruff black mypy boto3 2>$null
}

# ── Go ────────────────────────────────────────────────────────────────────────
if (-not (Have go)) {
  Log "Installing Go"
  Winget-Install "GoLang.Go" "Go"
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
              [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# ── Rust via rustup ───────────────────────────────────────────────────────────
if (-not (Have rustup)) {
  Log "Installing Rust via rustup"
  Winget-Install "Rustlang.Rustup" "Rustup"
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
              [System.Environment]::GetEnvironmentVariable("Path", "User")
}

if (Have rustup) {
  rustup update stable
  rustup component add clippy rustfmt
}

Log "Runtimes installed."
