#!/usr/bin/env python3
import json
import os
import yaml

# Get the absolute path to the project root
SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, ".."))
TERRAFORM_DIR = os.path.join(PROJECT_ROOT, "terraform")
ANSIBLE_DIR = os.path.join(PROJECT_ROOT, "ansible")

# Move to terraform directory
os.chdir(TERRAFORM_DIR)

# Get terraform output
output = os.popen("terraform output -json").read()
tf = json.loads(output)

# Build Ansible inventory structure
inventory = {
    "all": {
        "hosts": {
            "web1": {
                "ansible_host": tf["web1_public_ip"]["value"]
            },
            "web2": {
                "ansible_host": tf["web2_public_ip"]["value"]
            },
            "db": {
                "ansible_host": tf["db_public_ip"]["value"],      # SSH access
                "private_ip": tf["db_private_ip"]["value"]         # Internal access
            }
        },
        "vars": {
            "ansible_user": "ubuntu",
            "ansible_ssh_private_key_file": os.path.expanduser("~/.ssh/dxo-key.pem")
        }
    }
}

# Write to ansible inventory
inventory_file = os.path.join(ANSIBLE_DIR, "inventory.yml")
with open(inventory_file, "w") as f:
    yaml.dump(inventory, f, default_flow_style=False)

print("Inventory written to ansible/inventory.yml")
