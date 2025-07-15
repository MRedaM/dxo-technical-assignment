#!/usr/bin/env python3
import json
import os
import yaml

# Move to terraform directory
os.chdir("terraform")

# Get terraform output
output = os.popen("terraform output -json").read()
tf = json.loads(output)

# Return to root directory
os.chdir("..")

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
with open("ansible/inventory.yml", "w") as f:
    yaml.dump(inventory, f, default_flow_style=False)

print("✅ Inventory written to ansible/inventory.yml")
