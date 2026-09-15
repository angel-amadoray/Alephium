# Alephium Library
This directory contains the technical documentation for the project's infrastructure, deployed on Oracle Cloud Infrastructure (OCI) using Terraform and exclusively leveraging Always Free Tier resources.

## Index
| Document        | Description                                               |
| --------------- | --------------------------------------------------------- |
| architecture.md | Overview of the 3-tier architecture and layer diagram     |
| networking.md   | VCN, subnets, gateways, route tables, and security lists  |
| compute.md      | Compute instances, shapes, images, and cloud-init scripts |
| storage-iam.md  | Object Storage (image bucket) and IAM policies            |
| resources.md    | Complete inventory of all deployed resources              |

## Project
Build a library web application with Django to practice:

* Deploying 3-tier architectures on OCI
* Infrastructure as Code (IaC) with Terraform
* Exclusive use of Always Free resources

## Current Status
* Phase 1 completed (base infrastructure deployed with Terraform)
* Pending: Import the Autonomous Database into the Terraform state (created manually)
* Next up: Phase 2 - Django application configuration

🔗 Repository
github.com/tu-usuario/alephium-library