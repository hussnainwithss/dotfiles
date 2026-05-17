#!/usr/bin/env bash
# devops.sh — DevOps, cloud, and K8s toolchain (macOS + Linux)
# macOS: most tools come from Brewfile. This script handles Linux installs
# and cross-platform post-install config.
set -euo pipefail

log()  { echo ""; echo "==> $*"; }
have() { command -v "$1" &>/dev/null; }
OS="$(uname -s)"

# ── kubectl ───────────────────────────────────────────────────────────────────
if ! have kubectl; then
  log "Installing kubectl"
  if [[ "$OS" == "Darwin" ]]; then
    brew install kubectl
  else
    KUBE_VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt)
    ARCH=$(uname -m); [[ "$ARCH" == "x86_64" ]] && ARCH="amd64"; [[ "$ARCH" == "aarch64" ]] && ARCH="arm64"
    curl -Lo /tmp/kubectl "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${ARCH}/kubectl"
    chmod +x /tmp/kubectl
    sudo mv /tmp/kubectl /usr/local/bin/kubectl
  fi
fi

# ── Helm ─────────────────────────────────────────────────────────────────────
if ! have helm; then
  log "Installing Helm"
  if [[ "$OS" == "Darwin" ]]; then
    brew install helm
  else
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  fi
fi

# ── k9s ──────────────────────────────────────────────────────────────────────
if ! have k9s; then
  log "Installing k9s"
  if [[ "$OS" == "Darwin" ]]; then
    brew install k9s
  else
    K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep -oP '"tag_name": "\K[^"]+')
    ARCH=$(uname -m); [[ "$ARCH" == "x86_64" ]] && ARCH="amd64"; [[ "$ARCH" == "aarch64" ]] && ARCH="arm64"
    curl -Lo /tmp/k9s.tar.gz \
      "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_${ARCH}.tar.gz"
    tar -xzf /tmp/k9s.tar.gz -C /tmp k9s
    sudo mv /tmp/k9s /usr/local/bin/k9s
  fi
fi

# ── minikube ──────────────────────────────────────────────────────────────────
if ! have minikube; then
  log "Installing minikube"
  if [[ "$OS" == "Darwin" ]]; then
    brew install minikube
  else
    ARCH=$(uname -m); [[ "$ARCH" == "x86_64" ]] && ARCH="amd64"; [[ "$ARCH" == "aarch64" ]] && ARCH="arm64"
    curl -Lo /tmp/minikube \
      "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-${ARCH}"
    chmod +x /tmp/minikube
    sudo mv /tmp/minikube /usr/local/bin/minikube
  fi
fi

# ── Taskfile (task) ──────────────────────────────────────────────────────────
if ! have task; then
  log "Installing Taskfile runner"
  if [[ "$OS" == "Darwin" ]]; then
    brew install go-task
  else
    sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
  fi
fi

# ── Terraform ─────────────────────────────────────────────────────────────────
if ! have terraform; then
  log "Installing Terraform"
  if [[ "$OS" == "Darwin" ]]; then
    brew tap hashicorp/tap && brew install hashicorp/tap/terraform
  else
    ARCH=$(uname -m); [[ "$ARCH" == "x86_64" ]] && ARCH="amd64"; [[ "$ARCH" == "aarch64" ]] && ARCH="arm64"
    TF_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
    curl -Lo /tmp/terraform.zip \
      "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${ARCH}.zip"
    unzip -o /tmp/terraform.zip -d /tmp
    sudo mv /tmp/terraform /usr/local/bin/terraform
    rm /tmp/terraform.zip
  fi
fi

# ── Pulumi ────────────────────────────────────────────────────────────────────
if ! have pulumi; then
  log "Installing Pulumi"
  if [[ "$OS" == "Darwin" ]]; then
    brew install pulumi
  else
    curl -fsSL https://get.pulumi.com | sh
  fi
fi

# ── AWS CLI v2 ────────────────────────────────────────────────────────────────
if ! have aws; then
  log "Installing AWS CLI v2"
  if [[ "$OS" == "Darwin" ]]; then
    brew install awscli
  else
    ARCH=$(uname -m)
    [[ "$ARCH" == "aarch64" ]] && ARCH="aarch64" || ARCH="x86_64"
    curl -Lo /tmp/awscliv2.zip \
      "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip"
    unzip -o /tmp/awscliv2.zip -d /tmp
    sudo /tmp/aws/install --update
    rm -rf /tmp/aws /tmp/awscliv2.zip
  fi
fi

# ── Google Cloud SDK ──────────────────────────────────────────────────────────
if ! have gcloud; then
  log "Installing Google Cloud SDK"
  if [[ "$OS" == "Darwin" ]]; then
    brew install google-cloud-sdk
  else
    curl -fsSL https://sdk.cloud.google.com | bash -s -- --disable-prompts
    # shellcheck source=/dev/null
    source "$HOME/google-cloud-sdk/path.bash.inc" 2>/dev/null || true
  fi
fi

# ── Azure CLI ─────────────────────────────────────────────────────────────────
if ! have az; then
  log "Installing Azure CLI"
  if [[ "$OS" == "Darwin" ]]; then
    brew install azure-cli
  else
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  fi
fi

# ── kubectl plugins via krew ───────────────────────────────────────────────────
if have kubectl && ! kubectl krew version &>/dev/null 2>&1; then
  log "Installing krew (kubectl plugin manager)"
  (
    set -x
    cd "$(mktemp -d)"
    OS_LC="$(uname | tr '[:upper:]' '[:lower:]')"
    ARCH_LC="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')"
    KREW_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/krew/releases/latest | grep -oP '"tag_name": "\K[^"]+')
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/${KREW_VERSION}/krew-${OS_LC}_${ARCH_LC}.tar.gz"
    tar zxf "krew-${OS_LC}_${ARCH_LC}.tar.gz"
    "./krew-${OS_LC}_${ARCH_LC}" install krew
  )
fi

log "DevOps tools installed."
