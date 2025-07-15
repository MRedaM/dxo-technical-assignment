#!/bin/bash

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"
ANSIBLE_DIR="$PROJECT_ROOT/ansible"
INVENTORY_FILE="$ANSIBLE_DIR/inventory.yml"
KEY_FILE="$HOME/.ssh/dxo-key.pem"
PYTHON_SCRIPT="$PROJECT_ROOT/scripts/generate_inventory.py"

echo "Planning Terraform..."
cd "$TERRAFORM_DIR"
terraform plan

echo "Applying Terraform..."
terraform apply -auto-approve

echo "Generating Ansible inventory..."
python3 "$PYTHON_SCRIPT"

echo "Accepting SSH fingerprints for all hosts..."
for host in web1 web2 db; do
  ip=$(python3 -c "
import yaml
with open('$INVENTORY_FILE') as f:
    data = yaml.safe_load(f)
print(data['all']['hosts']['$host']['ansible_host'])
")
  echo "Waiting for $host ($ip) to become reachable..."
  until nc -z $ip 22; do
    sleep 2
  done

  echo "Connecting to $host ($ip) to accept fingerprint..."
  ssh -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=~/.ssh/known_hosts \
      -i "$KEY_FILE" ubuntu@$ip "echo 'Fingerprint accepted for $host'" || {
    echo "SSH failed to $host"
    exit 1
  }
done


echo "Running Ansible playbook..."
cd "$ANSIBLE_DIR"
ansible-playbook playbook.yml -i inventory.yml

echo "Deployment complete!"
