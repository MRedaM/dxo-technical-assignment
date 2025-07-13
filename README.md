# DXO Technical Assignment

## 📘 Overview

This project implements a production-like, fully automated infrastructure setup and configuration for a high-availability web application on AWS. It uses **Terraform** for infrastructure 
provisioning and **Ansible** for configuration management, delivering:

- Scalable, self-healing Nginx web servers
- PostgreSQL on EC2 with remote access
- Load balancing, SSL (Let's Encrypt), and DNS via GoDaddy domain

---

## 🛠️ Tech Stack

| Layer           | Technology                   |
|----------------|------------------------------|
| Cloud Provider | AWS (us-east-1)              |
| Infrastructure | Terraform                    |
| Provisioning   | Ansible                      |
| Web Server     | Nginx on Ubuntu EC2          |
| Database       | PostgreSQL on Ubuntu EC2     |
| SSL            | Let's Encrypt via Certbot    |
| Domain         | GoDaddy - `mydevprojects.eu` |
| Watchdog       | systemd service recovery     |

---

## 🌐 Architecture

                         +-----------------------+
                         |  mydevprojects.eu     |
                         +-----------+-----------+
                                     |
                         +-----------v-----------+
                         |    AWS Load Balancer   |
                         +-----------+-----------+
                                     |
           +-------------------------+------------------------+
           |                                                  |
   +-------v-------+                                  +-------v-------+
   | Web Server #1 |                                  | Web Server #2 |
   | (Nginx + App) |                                  | (Nginx + App) |
   +-------+-------+                                  +-------+-------+
           \                                                  /
            \                                                /
             \                                              /
              +------------------+-------------------------+
                                 |
                      +----------v----------+
                      |   PostgreSQL EC2     |
                      +----------------------+

---

## 🚀 Features

- ✅ Terraform-managed AWS VPC, subnets, security groups, EC2 instances
- ✅ Ansible configuration for PostgreSQL, Nginx, Certbot
- ✅ SSL via Let's Encrypt + GoDaddy DNS
- ✅ Automatic failover with systemd watchdog
- ✅ HA: web instances in separate subnets

---

## 🔧 Deployment Steps

### 1. Clone the Project
git clone https://github.com/MRedaM/dxo-technical-assignment.git


DXO-Technical-Assignment/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── ansible/
│   ├── inventory.yml
│   ├── site.yml
│   └── roles/
│       ├── webserver/
│       ├── database/
│       ├── ssl/
│       └── selfhealing/
├── scripts/
│   └── bootstrap.sh
├── .ssh/
│   └── dxo-key.pem
└── README.md


