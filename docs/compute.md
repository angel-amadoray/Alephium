
## Deployed Instances

| Instance | Terraform Logical Name           | Shape                    | Subnet                | Public IP |
| -------- | -------------------------------- | ------------------------ | --------------------- | --------- |
| Web      | `oci_core_instance.web_instance` | `VM.Standard.E2.1.Micro` | `alephium_web_subnet` | Yes       |
| App      | `oci_core_instance.app_instance` | `VM.Standard.E2.1.Micro` | `alephium_app_subnet` | No        |

## Always Free Shape Specifications

| Property     | Value                    |
| ------------ | ------------------------ |
| Shape        | `VM.Standard.E2.1.Micro` |
| Architecture | x86_64 (AMD)             |
| OCPU         | 1/8                      |
| RAM          | 1 GB                     |
| Cost         | Free (Always Free)       |

## Operating System Image

| Property         | Value                      |
| ---------------- | -------------------------- |
| Data Source      | `data.oci_core_images.ol8` |
| Operating System | Oracle Linux 8             |
| Filter by shape  | `VM.Standard.E2.1.Micro`   |

## cloud-init Scripts

Initialization scripts run automatically the first time each instance boots up.

### `user-data/web-instance.sh`

Installs and configures:

* `nginx` (web server and reverse proxy)
* Proxy configuration pointing to the App instance at `10.0.2.X:8000`
* `systemd` service for Nginx

### `user-data/app-instance.sh`

Installs and prepares:

* `python3.11`, `pip`, `gcc`, `libffi-devel`, `openssl-devel`
* `django` user (to run Gunicorn unprivileged)
* `/opt/django` directory (where code will reside)
* `systemd` service for Gunicorn (pending startup after cloning code)

