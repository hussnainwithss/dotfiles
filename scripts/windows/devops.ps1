# devops.ps1 — DevOps and cloud toolchain on Windows
function Log($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Have($cmd) { $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue) }

function Winget-Install($id, $name) {
  if (-not (winget list --id $id -e 2>$null | Select-String $id)) {
    Log "Installing $name"
    winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements
  } else {
    Write-Host "  $name already installed"
  }
}

function Scoop-Install($pkg) {
  if (-not (scoop list $pkg 2>$null | Select-String $pkg)) { scoop install $pkg }
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

# ── kubectl ───────────────────────────────────────────────────────────────────
if (-not (Have kubectl)) {
  Log "Installing kubectl"
  Winget-Install "Kubernetes.kubectl" "kubectl"
}

# ── Helm ─────────────────────────────────────────────────────────────────────
if (-not (Have helm)) {
  Log "Installing Helm"
  Scoop-Install "helm"
}

# ── k9s ──────────────────────────────────────────────────────────────────────
if (-not (Have k9s)) {
  Log "Installing k9s"
  Scoop-Install "k9s"
}

# ── minikube ──────────────────────────────────────────────────────────────────
if (-not (Have minikube)) {
  Log "Installing minikube"
  Winget-Install "Kubernetes.minikube" "minikube"
}

# ── Taskfile ──────────────────────────────────────────────────────────────────
if (-not (Have task)) {
  Log "Installing Taskfile runner"
  Scoop-Install "task"
}

# ── Terraform ─────────────────────────────────────────────────────────────────
if (-not (Have terraform)) {
  Log "Installing Terraform"
  Winget-Install "Hashicorp.Terraform" "Terraform"
}

# ── Pulumi ────────────────────────────────────────────────────────────────────
if (-not (Have pulumi)) {
  Log "Installing Pulumi"
  Winget-Install "Pulumi.Pulumi" "Pulumi"
}

# ── AWS CLI ───────────────────────────────────────────────────────────────────
if (-not (Have aws)) {
  Log "Installing AWS CLI"
  Winget-Install "Amazon.AWSCLI" "AWS CLI"
}

# ── Google Cloud SDK ──────────────────────────────────────────────────────────
if (-not (Have gcloud)) {
  Log "Installing Google Cloud SDK"
  Winget-Install "Google.CloudSDK" "Google Cloud SDK"
}

# ── Azure CLI ─────────────────────────────────────────────────────────────────
if (-not (Have az)) {
  Log "Installing Azure CLI"
  Winget-Install "Microsoft.AzureCLI" "Azure CLI"
}

# ── Refresh PATH ───────────────────────────────────────────────────────────────
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

Log "DevOps tools installed."
