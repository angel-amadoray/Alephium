# Project Architecture

## Overview

The project follows a classic **3-tier** architecture, where each layer lives in a separate subnet with independent security rules. This minimizes exposure: only the Web layer touches the Internet, while the business logic and data remain in private subnets.

## Layer Diagram
┌─────────────────────────┐
│ INTERNET │
└────────────┬────────────┘
│ HTTP/HTTPS (80, 443)
▼
┌───────────────────────────────────────────────────────────┐
│ VCN: alephium-vcn (10.0.0.0/16) │
│ │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ WEB LAYER (Public) - 10.0.1.0/24 │ │
│ │ ├─ Internet Gateway │ │
│ │ ├─ Instance: web-instance (Nginx) │ │
│ │ └─ Security List: HTTP/HTTPS/SSH from 0.0.0.0/0 │ │
│ └──────────────────────┬──────────────────────────────┘ │
│ │ Port 8000 (internal) │
│ ▼ │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ APP LAYER (Private) - 10.0.2.0/24 │ │
│ │ ├─ Instance: app-instance (Django + Gunicorn) │ │
│ │ └─ Security List: Port 8000 from 10.0.1.0/24 │ │
│ └──────────────────────┬──────────────────────────────┘ │
│ │ Port 1522 (internal) │
│ ▼ │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ DB LAYER (Private) - 10.0.3.0/24 │ │
│ │ ├─ Autonomous Database (ATP) Always Free │ │
│ │ └─ Security List: Port 1522 from 10.0.2.0/24 │ │
│ └─────────────────────────────────────────────────────┘ │
│ │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ ADDITIONAL SERVICES │ │
│ │ └─ Object Storage: bucket "alephium-media" │ │
│ └─────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────┘

## Design Principles

1. **Layer Segmentation:** Each layer has its own subnet and firewall rules. 
2. **Least Privilege Principle:** The App layer only accepts traffic from the Web layer. The DB only accepts traffic from the App layer.
3. **Always Free Resources:** The entire design uses OCI Free Tier resources exclusively.
4. **Infrastructure as Code:** Everything is defined in Terraform and version-controlled in Git.

## Request Flow

1. A user opens `http://<PUBLIC_WEB_IP>` in their browser.
2. The request reaches the **Internet Gateway** and enters the Web subnet.
3. **Nginx** (on `web-instance`) receives the request on port 80.
4. Nginx acts as a reverse proxy and forwards the request to `http://10.0.2.X:8000` (the App).
5. **Gunicorn** (on `app-instance`) receives the request and hands it to **Django**.
6. Django queries the **Autonomous Database** on port 1522 to retrieve data.
7. Django sends the response back to Gunicorn → Nginx → Internet → User.

## Always Free Tier Limitations

| Resource                     | Project Usage                  |
| ---------------------------- | ------------------------------ |
| VM.Standard.A1.Flex (ARM)    | **Not used** (out of capacity) |
| VM.Standard.E2.1.Micro (AMD) | **2 instances** (web + app)    |
| Autonomous Database          | **1 DB** (alephium-atp)        |
| Object Storage               | **1 bucket**                   |
| Load Balancer                | Replaced by Nginx              |
| NAT Gateway                  | Not used (App is private)      |
