
Complete list of all deployed resources, along with their logical Terraform name, actual OCI display name, and purpose.

## Summary by State

| State                | Count | Notes                                            |
| -------------------- | ----- | ------------------------------------------------ |
| Managed by Terraform | 15    | Tracked in `terraform.tfstate`                   |
| ⚠️ Manually created  | 1     | Autonomous Database (pending `terraform import`) |

## Complete Table

### Networking

| Terraform Resource | OCI Type | Display Name | Details |
| --- | --- | --- | --- |
| `oci_core_vcn.alephium_vcn` | VCN | `alephium-vcn` | CIDR `10.0.0.0/16` |
| `oci_core_internet_gateway.igw` | Internet Gateway | `alephium-igw` | Internet outbound for Web |
| `oci_core_service_gateway.sg` | Service Gateway | `alephium-sg` | Private access to OCI services |
| `oci_core_route_table.web_rt` | Route Table | `alephium-web-rt` | Route `0.0.0.0/0` → IGW |
| `oci_core_subnet.alephium_web_subnet` | Subnet | `alephium-web-subnet` | `10.0.1.0/24` (public) |
| `oci_core_subnet.alephium_app_subnet` | Subnet | `alephium-app-subnet` | `10.0.2.0/24` (private) |
| `oci_core_subnet.alephium_db_subnet` | Subnet | `alephium-db-subnet` | `10.0.3.0/24` (private) |

### Security

| Terraform Resource | OCI Type | Display Name | Details |
| --- | --- | --- | --- |
| `oci_core_security_list.web_sl` | Security List | `alephium-web-sl` | Inbound HTTP/HTTPS/SSH |
| `oci_core_security_list.app_sl` | Security List | `alephium-app-sl` | Port 8000 from Web |
| `oci_core_security_list.db_sl` | Security List | `alephium-db-sl` | Port 1522 from App |

### Compute

| Terraform Resource | OCI Type | Display Name | Details |
| --- | --- | --- | --- |
| `oci_core_instance.web_instance` | Instance | `web-instance` | `VM.Standard.E2.1.Micro`, Public IP |
| `oci_core_instance.app_instance` | Instance | `app-instance` | `VM.Standard.E2.1.Micro`, Private IP only |

### Database

| Terraform Resource | OCI Type | Display Name | Status |
| --- | --- | --- | --- |
| `oci_database_autonomous_database.alephium_db` | Autonomous Database | `alephium_atp` | ⚠️ **Manually created** — pending import |

### Storage

| Terraform Resource                      | OCI Type | Name             | Details                               |
| --------------------------------------- | -------- | ---------------- | ------------------------------------- |
| `oci_objectstorage_bucket.media_bucket` | Bucket   | `alephium-media` | Stores cover images and author photos |

### IAM

| Terraform Resource                                  | OCI Type      | Name                   | Details                                 |
| --------------------------------------------------- | ------------- | ---------------------- | --------------------------------------- |
| `oci_identity_dynamic_group.library_instances`      | Dynamic Group | `library-instances-dg` | Groups instances within the compartment |
| `oci_identity_policy.library_object_storage_policy` | Policy        | `library-media-policy` | Allows instances to access the bucket   |

### Outputs (Terraform Outputs)

| Output                             | Description                       |
| ---------------------------------- | --------------------------------- |
| `web_instance_public_ip`           | Public IP of the Web instance     |
| `app_instance_private_ip`          | Private IP of the App instance    |
| `autonomous_db_connection_strings` | DB connection strings (sensitive) |
| object_storage_bucket_name`        | Bucket name                       |
