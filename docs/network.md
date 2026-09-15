
# Network Configuration

## VCN 

| Property               | Value                       |
| ---------------------- | --------------------------- |
| Terraform Logical Name | `oci_core_vcn.alephium_vcn` |
| Display Name           | `alephium-vcn`              |
| CIDR Block             | `10.0.0.0/16`               |
| DNS Label              | (verify in `network.tf`)    |
| Compartment            | `var.compartment_ocid`      |

The VCN is the foundation where the entire infrastructure resides. The `10.0.0.0/16` range allows up to 65,536 private IP addresses. 

## Subnets

| Subnet                | CIDR          | Type    | Route     | Purpose                 |
| --------------------- | ------------- | ------- | --------- | ----------------------- |
| `alephium_web_subnet` | `10.0.1.0/24` | Public  | IGW       | Nginx server (frontend) |
| `alephium_app_subnet` | `10.0.2.0/24` | Private | (default) | Django server (backend) |
| `alephium_db_subnet`  | `10.0.3.0/24` | Private | (default) | Autonomous Database     |
## Gateways

### Internet Gateway (IGW)

| Property     | Value                                                       |
| ------------ | ----------------------------------------------------------- |
| Logical Name | `oci_core_internet_gateway.igw`                             |
| Display Name | `alephium-igw`                                              |
| Purpose      | Allow inbound/outbound Internet traffic from the Web subnet |

### Service Gateway (SGW)

| Property     | Value                                                                                 |
| ------------ | ------------------------------------------------------------------------------------- |
| Logical Name | `oci_core_service_gateway.sg`                                                         |
| Display Name | `alephium-sg`                                                                         |
| Purpose      | Private access to OCI services (Object Storage, etc.) without going over the Internet |

## Route Tables

| Table             | Terraform Resource            | Rule               | Applied To         |
| ----------------- | ----------------------------- | ------------------ | ------------------ |
| `alephium-web-rt` | `oci_core_route_table.web_rt` | `0.0.0.0/0` → IGW  | Web Subnet         |
| Default           | (implicit)                    | No Internet routes | App and DB Subnets |

## Security Lists

Security Lists act as the firewall for each layer. Each subnet has its own security list.

### Web Security List (`web_sl`)

| Direction | Protocol | Port | Source/Destination | Purpose             |
| --------- | -------- | ---- | ------------------ | ------------------- |
| Ingress   | TCP      | 80   | `0.0.0.0/0`        | Public HTTP         |
| Ingress   | TCP      | 443  | `0.0.0.0/0`        | Public HTTPS        |
| Egress    | All      | All  | `0.0.0.0/0`        | Unrestricted egress |

### App Security List (`app_sl`)

| Direction | Protocol | Port | Source/Destination | Purpose                |
| --------- | -------- | ---- | ------------------ | ---------------------- |
| Ingress   | TCP      | 8000 | `10.0.1.0/24`      | Gunicorn from Web      |
| Ingress   | TCP      | 22   | `10.0.1.0/24`      | SSH from Web (bastion) |
| Egress    | All      | All  | `0.0.0.0/0`        | Unrestricted egress    |

### DB Security List (`db_sl`)

| Direction | Protocol | Port | Source/Destination | Purpose |
| --- | --- | --- | --- | --- |
| Ingress | TCP | 1522 | `10.0.2.0/24` | Autonomous DB from App |
| Egress | All | All | `0.0.0.0/0` | Unrestricted egress |

## Allowed Traffic Flow

Internet  --(80/443)--> Web Subnet  --(8000)--> App Subnet --(1522)--> DB Subnet

Every other flow is restricted