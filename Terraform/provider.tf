terraform {
    required_version = ">= 1.0"
    required_providers {
        oci = {
            source = "oracle/oci"
            version = ">= 9.8.0"
        }
        http = {
            source = "hashicorp/http"
            version = ">= 3.4"
        }
    }
}

provider "oci" {
    region = var.region
    tenancy_ocid = var.tenancy_ocid
    user_ocid = var.user_ocid
    fingerprint = var.fingerprint
    private_key_path = var.private_key_path
}