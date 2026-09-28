# Image Storage (OCI Object Storage)

## Overview

All user-uploaded media (book covers and author photos) is stored in **OCI Object Storage** instead of the local filesystem of the compute instance.

## Decision

**Chosen solution:** OCI Object Storage accessed through its **S3-compatible API**, integrated into Django via `django-storages` (`storages.backends.s3.S3Storage`) using `boto3` as the underlying client.

### Why the S3-compatible API and not the native OCI SDK?

| Approach | Pros | Cons |
|----------|------|------|
| **S3-compatible API** (chosen) | First-class support in `django-storages`, minimal configuration, well-documented, uses `boto3` which is battle-tested | Requires the `aws-chunked` workaround (see below); pulls in `boto3` as a dependency |
| **Native OCI SDK** (`oci` package) | Pure Oracle stack, uses Instance Principals directly | No maintained Django storage backend; requires a custom `Storage` subclass |

The S3-compatible API is the officially supported path for Django + OCI Object Storage and is what Oracle documents in its own guides.

## Architecture

```
Django (admin upload)
        │
        ▼
django-storages (S3Storage backend)
        │
        ▼
boto3 client  ──HTTPS──▶  OCI Object Storage
                          https://{namespace}.compat.objectstorage.{region}.oraclecloud.com
                                    │
                                    ▼
                          Bucket: alephium-media
                              ├── authors/
                              └── covers/
```

## Configuration

### Django settings (`library/settings.py`)

```python
# --- OCI Object Storage ---
OCI_NAMESPACE = os.getenv("OCI_NAMESPACE")
OCI_BUCKET_NAME = os.getenv("OCI_BUCKET_NAME")
OCI_REGION = os.getenv("OCI_REGION")
OCI_SECRET_KEY = os.getenv("OCI_CUSTOMER_SECRET_KEY")
OCI_ACCESS_KEY = os.getenv("OCI_CUSTOMER_ACCESS_KEY")
OCI_BUCKET_ENDPOINT_URL = (
    f"https://{OCI_NAMESPACE}.compat.objectstorage.{OCI_REGION}.oraclecloud.com"
)

# Workaround for OCI: disable AWS chunked encoding
os.environ["AWS_REQUEST_CHECKSUM_CALCULATION"] = "when_required"
os.environ["AWS_RESPONSE_CHECKSUM_VALIDATION"] = "when_required"

STORAGES = {
    "default": {
        "BACKEND": "storages.backends.s3.S3Storage",
        "OPTIONS": {
            "access_key": OCI_ACCESS_KEY,
            "secret_key": OCI_SECRET_KEY,
            "bucket_name": OCI_BUCKET_NAME,
            "region_name": OCI_REGION,
            "endpoint_url": OCI_BUCKET_ENDPOINT_URL,
        },
    },
    "staticfiles": {
        "BACKEND": "django.contrib.staticfiles.storage.StaticFilesStorage",
    },
}
```

## Environment Variables

| Variable                  | Description                             | Where to find it                                 |
| ------------------------- | --------------------------------------- | ------------------------------------------------ |
| `OCI_NAMESPACE`           | Object Storage namespace of the tenancy | OCI Console → Storage → Buckets → Bucket details |
| `OCI_BUCKET_NAME`         | Name of the bucket (`alephium-media`)   | Terraform / OCI Console                          |
| `OCI_REGION`              | OCI region identifier                   | Same as `provider.tf`                            |
| `OCI_CUSTOMER_ACCESS_KEY` | Customer Secret Key access key          | OCI Console → My profile → Customer Secret Keys  |
| `OCI_CUSTOMER_SECRET_KEY` | Customer Secret Key secret              | Shown only once at creation time                 |
## Authentication Strategy

| Environment                    | Method                                                                                             | Notes                                                                                |
| ------------------------------ | -------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| **Local development** (laptop) | Customer Secret Keys (access key + secret key)                                                     | The laptop has no Instance Principal identity, so explicit credentials are required. |
| **Production** (VM App)        | To be implemented in Phase 3 — either Instance Principals or Customer Secret Keys stored in the VM | See "Future Work" section below.                                                     |

## The `aws-chunked` Issue

### Symptom

When uploading a file through the Django admin, the following error appears:

```
ClientError at /admin/books/author/2/change/
An error occurred (NotImplemented) when calling the PutObject operation:
AWS chunked encoding not supported.
```

### Root Cause

`boto3` computes and sends a trailing checksum by default, using the header `Content-Encoding: aws-chunked`. OCI's S3-compatible API **does not support** this encoding and rejects the request with `501 NotImplemented`.

### Solution

Force `boto3` to compute checksums only when strictly required, by setting two environment variables **before** the `boto3` client is instantiated:

```python
os.environ["AWS_REQUEST_CHECKSUM_CALCULATION"] = "when_required"
os.environ["AWS_RESPONSE_CHECKSUM_VALIDATION"] = "when_required"
```

These are placed at the top of `settings.py`, right after loading the `.env`, so they are guaranteed to be applied in every environment (local and VM). The default value is `when_supported`, which is what triggers the `aws-chunked` behavior.

### References

- Oracle Cloud documentation: *Using the Amazon S3 Compatibility API*
- `boto3` configuration reference: *Data integrity protections*