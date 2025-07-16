
# DXO Technical Assignment

## Overview

This project implements a production-like, fully automated infrastructure and configuration pipeline for a high-availability web application on AWS. It leverages:

- **Terraform** to provision AWS infrastructure
- **Ansible** to configure PostgreSQL and Nginx
- **Ansible Vault** for securely managing secrets
- **Systemd** for Nginx self-healing
- **Bash & Python** for orchestration and automation

---

## Project Structure

```
DXO-Technical-Assignment/
├── terraform/                     # AWS VPC, EC2, ALB, Security Groups
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── ansible/                       # Ansible automation
│   ├── inventory.yml              # Auto-generated inventory (via Python)
│   ├── playbook.yml               # Main playbook
│   ├── group_vars/
│   │   └── all/
│   │       └── vault.yml          # PostgreSQL credentials (encrypted)
│   └── roles/
│       ├── database/              # PostgreSQL installation & setup
│       └── webserver/             # Nginx setup, DB content fetch, SSL
├── scripts/
│   ├── deploy.sh                  # Full pipeline: Terraform → Inventory → Ansible
│   └── generate_inventory.py      # Parses Terraform outputs into Ansible inventory
├── .ssh/
│   └── dxo-key.pem                # SSH key (not included in repo)
└── README.md
```

---

## Tech Stack

| Layer           | Technology                   |
|----------------|------------------------------|
| Cloud Provider | AWS (us-east-1)              |
| Infrastructure | Terraform                    |
| Provisioning   | Ansible                      |
| Web Server     | Nginx on Ubuntu EC2          |
| Database       | PostgreSQL + Ansible Vault   |
| SSL            | Self-signed (OpenSSL)        |
| Load Balancer  | AWS Application Load Balancer |
| Orchestration  | Bash + Python                |

---

## Architecture

```
                 +------------------------+
                 |    Public Domain/IP    | 
		 |https://mydevprojects.eu|
                 +-----------+------------+
                             |
                 +-----------v-----------+
                 |   AWS Load Balancer   |
                 +-----------+-----------+
                             |
     +-----------------------+-----------------------+
     |                                               |
+----v----+                                   +------v-----+
| Web #1  |                                   |  Web #2     |
| Nginx   |                                   |  Nginx      |
+----+----+                                   +------+------+
     |                                               |
     +-------------------+---------------------------+
                         |
                +--------v--------+
                |   PostgreSQL    |
                | (Private IP)    |
                +----------------+
```

---

## Features

✅ Fully automated setup using `scripts/deploy.sh`  
✅ PostgreSQL with **password authentication** (secured with Ansible Vault)  
✅ Private IP communication between web and DB  
✅ Nginx auto-restarts on failure via `systemd override`  
✅ Self-signed SSL certificate with HTTPS redirect  
✅ Dynamic index.html generation using DB query  
✅ Auto-decryption via `--vault-password-file`  

---


## Using Ansible Vault

- Store your vault password in: `~/.ansible/vault_pass.txt`
- Encrypt secrets:

```bash
ansible-vault encrypt ansible/group_vars/db/vault.yml --vault-password-file ~/.ansible/vault_pass.txt
```

- Playbook usage:

```bash
ansible-playbook playbook.yml -i inventory.yml --vault-password-file ~/.ansible/vault_pass.txt
```

---

## Usage

### 1. Clone the Repository

```bash
git clone https://github.com/MRedaM/dxo-technical-assignment.git
cd dxo-technical-assignment
```

### 2. Run the Full Pipeline

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

This script will:

- `terraform plan && apply`
- Generate `inventory.yml` from Terraform outputs
- SSH into each EC2 host to accept SSH fingerprints
- Run the Ansible playbook with Vault decryption

---

## Test the App

After deployment, visit the **Load Balancer DNS name** or **web server IPs** in your browser.

You should see:

- A greeting from the specific web server
- Content pulled live from PostgreSQL (`mytable.content`)

---

## Notes

- Make sure your SSH key `dxo-key.pem` is stored in `~/.ssh/` and has `chmod 400` permissions
- Do not commit `vault_pass.txt` to source control
- ALB listener uses HTTPS (port 443) with a self-signed certificate