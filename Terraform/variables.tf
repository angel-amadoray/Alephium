variable "region" {
    description = "OCI region."
    type = string
}

variable "tenancy_ocid" {
    description = "OCI tenancy OCID."
    type = string
}

variable "user_ocid" {
    description = "OCI user OCID."
    type = string
}

variable "fingerprint" {
    description = "Fingerprint of the user's public key."
    type = string
}

variable "private_key_path" {    
    description = "Path to the private key file."
    type = string
}

variable "compartment_ocid" {
    description = "OCID of the compartment."
    type = string
}

variable "ssh_public_key" {
    description = "Path to the SSH public key file."
    type = string
}

variable "db_password" {
    description = "Password for the database."
    type = string
}