
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
│   │   └── db/
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
