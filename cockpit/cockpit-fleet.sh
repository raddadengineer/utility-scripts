#!/bin/bash

# ===== 🧩 Configuration =====
# List of IPs or hostnames for your target fleet
HOSTS=("192.168.1.101" "192.168.1.102" "192.168.1.103")

# Remote username with sudo privileges on all hosts
USERNAME="youradminuser"

# Path to your public SSH key used for passwordless access
SSH_KEY="$HOME/.ssh/id_ed25519.pub"

# Create a log file with timestamp for tracking deployments
LOGFILE="fleet-install-$(date +%Y%m%d_%H%M%S).log"

# ===== 🎛️ Flags (set by CLI arguments) =====
INSTALL_ONLY=false   # Only perform install (skip key setup)
KEYS_ONLY=false      # Only deploy SSH keys (skip install)
PARALLEL=false       # Run installs in parallel (background)

# ===== 🧠 Argument Parsing =====
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --install-only) INSTALL_ONLY=true ;;    # --install-only: skip key deployment
    --keys-only) KEYS_ONLY=true ;;          # --keys-only: skip installation
    --parallel) PARALLEL=true ;;            # --parallel: install via background threads
    *) echo "⚠️ Unknown parameter passed: $1"; exit 1 ;;  # Catch unsupported flags
  esac
  shift
done

# ===== 📦 Cockpit Installation Commands (executed remotely) =====
REMOTE_COMMANDS=$(cat <<'EOF'
set -e  # Exit immediately if a command fails

# Detect and use appropriate package manager
if command -v apt &>/dev/null; then
  sudo apt update -y && sudo apt install -y cockpit cockpit-networkmanager
elif command -v dnf &>/dev/null; then
  sudo dnf update -y && sudo dnf install -y cockpit cockpit-networkmanager
else
  echo "❌ Unsupported package manager"
  exit 1
fi

# Enable and start the cockpit service
sudo systemctl enable --now cockpit.socket
EOF
)

# ===== 🔐 SSH Key Deployment Function =====
function deploy_keys() {
  echo "🔑 Deploying SSH keys to hosts..." | tee -a "$LOGFILE"
  for HOST in "${HOSTS[@]}"; do
    echo "➡️ [$HOST] Copying SSH key..." | tee -a "$LOGFILE"
    if ssh-copy-id -i "$SSH_KEY" "$USERNAME@$HOST"; then
      echo "✅ [$HOST] Key copied successfully" | tee -a "$LOGFILE"
    else
      echo "❌ [$HOST] Key copy failed" | tee -a "$LOGFILE"
    fi
  done
}

# ===== 🛠️ Cockpit Installation Function =====
function install_cockpit() {
  echo "🚀 Installing Cockpit on fleet..." | tee -a "$LOGFILE"
  for HOST in "${HOSTS[@]}"; do
    echo "🔧 [$HOST] Running install..." | tee -a "$LOGFILE"
    if ssh -o ConnectTimeout=5 "$USERNAME@$HOST" "$REMOTE_COMMANDS"; then
      echo "✅ [$HOST] Cockpit installed" | tee -a "$LOGFILE"
    else
      echo "❌ [$HOST] Install failed" | tee -a "$LOGFILE"
    fi
  done
}

# ===== 🧵 Parallel Install (background jobs) =====
function parallel_install() {
  echo "🚀 Parallel Cockpit install..." | tee -a "$LOGFILE"
  for HOST in "${HOSTS[@]}"; do
    echo "🔧 [$HOST] Installing in background..." | tee -a "$LOGFILE"
    ssh -o ConnectTimeout=5 "$USERNAME@$HOST" "$REMOTE_COMMANDS" \
      && echo "✅ [$HOST] Installed" >> "$LOGFILE" \
      || echo "❌ [$HOST] Failed" >> "$LOGFILE" &
  done
  wait  # Wait for all background jobs to complete
  echo "🧵 Parallel install complete." | tee -a "$LOGFILE"
}

# ===== 🧨 Main Execution =====
$KEYS_ONLY || deploy_keys
$INSTALL_ONLY || {
  $PARALLEL && parallel_install || install_cockpit
}

echo "📄 Log saved to $LOGFILE"
echo "🎉 Fleet setup complete."
