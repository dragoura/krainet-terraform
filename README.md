## Overview

This repository contains .
Ansible and Terraform for provisioning a DigitalOcean droplet, firewall rules, and DNS for the app are in this repo https://github.com/dragoura/krainet-terraform
The minimal Go + Echo microservice with Prometheus metrics, PostgreSQL integration, Docker (multi-stage, non-root), Nginx reverse proxy, GitLab CI/CD are here https://github.com/dragoura/krainet

### Components
- IaC: Terraform for DigitalOcean droplet, firewall, DNS A-record
- Ansible for droplet configuration

### Terraform
Provisions:
- DigitalOcean droplet for the app (Ubuntu 22.04)
- Firewall allowing 22/tcp, 80/tcp, 443/tcp
- DNS A-record for the app subdomain

Apply:
```
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
# fill variables
terraform init && terraform apply
```

### Notes
- Grafana is hosted on a separate droplet. Scraping of `/metrics` should be done by a Prometheus/Agent you control (on Grafana droplet or elsewhere).
- GitLab and its Registry are already hosted at `gitlab.julia-b.work` (currently unavailable).
