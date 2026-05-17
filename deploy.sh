#!/bin/bash
# ============================================================
# One-shot deploy script
# Usage: bash deploy.sh
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$SCRIPT_DIR/terraform"
ANSIBLE_DIR="$SCRIPT_DIR/ansible"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   SRE Project — Full Deploy              ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Step 1: Terraform ────────────────────────────────────────
echo ">>> STEP 1: Terraform — provision VM on GCP"
cd "$TF_DIR"

# Fix Windows-style path if running from WSL
if grep -q 'C:/' terraform.tfvars 2>/dev/null; then
  echo "    Fixing Windows SSH key path for WSL..."
  sed -i 's|C:/Users/[^/]*/\.ssh/|~/.ssh/|g' terraform.tfvars
fi

terraform init
terraform validate
terraform apply -auto-approve

# Get VM IP
VM_IP=$(terraform output -raw public_ip)
echo ""
echo "    VM IP: $VM_IP"

# ── Step 2: Update Ansible inventory ────────────────────────
echo ""
echo ">>> STEP 2: Update Ansible inventory with VM IP"
sed -i "s/REPLACE_WITH_VM_IP/$VM_IP/" "$ANSIBLE_DIR/inventory.ini"

# ── Step 3: Wait for VM to be SSH-ready ──────────────────────
echo ""
echo ">>> STEP 3: Waiting for VM to be SSH-ready (up to 3 min)..."
for i in $(seq 1 36); do
  if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 \
         -i ~/.ssh/id_rsa ubuntu@$VM_IP exit 2>/dev/null; then
    echo "    VM is ready!"
    break
  fi
  echo "    Attempt $i/36 — waiting 5s..."
  sleep 5
done

# ── Step 4: Ansible ──────────────────────────────────────────
echo ""
echo ">>> STEP 4: Ansible — configure & deploy"
cd "$ANSIBLE_DIR"
ansible-playbook site.yml -v

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║   DEPLOY COMPLETE                                        ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║   App:        http://$VM_IP                              ║"
echo "║   Grafana:    http://$VM_IP:3000  (admin/admin)          ║"
echo "║   Prometheus: http://$VM_IP:9090                         ║"
echo "╚══════════════════════════════════════════════════════════╝"
