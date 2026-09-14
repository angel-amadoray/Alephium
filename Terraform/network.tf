# virtual cloud network: alephium_vcn
resource "oci_core_vcn" "alephium_vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "alephium_vcn"
  dns_label      = "alephiumvcn"
}

# internet gateway for alephium_vcn
resource "oci_core_internet_gateway" "alephium_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.alephium_vcn.id
  display_name   = "alephium_igw"
}

# web route table for alephium_vcn
resource "oci_core_route_table" "alephium_web_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.alephium_vcn.id
  display_name   = "alephium_web_rt"

  route_rules {
    destination       = "0.0.0.0/0" # internet
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.alephium_igw.id
  }
}

# web subnet (public)
resource "oci_core_subnet" "alephium_web_subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.alephium_vcn.id
  display_name      = "alephium_web_subnet"
  cidr_block        = "10.0.1.0/24"
  dns_label         = "web"
  route_table_id    = oci_core_route_table.alephium_web_rt.id
  security_list_ids = [oci_core_security_list.alephium_web_sl.id]
}

# app subnet (private)
resource "oci_core_subnet" "alephium_app_subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.alephium_vcn.id
  cidr_block        = "10.0.2.0/24"
  display_name      = "alephium_app_subnet"
  dns_label         = "app"
  security_list_ids = [oci_core_security_list.alephium_app_sl.id]
}

# db subnet (private)
resource "oci_core_subnet" "alephium_db_subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.alephium_vcn.id
  cidr_block        = "10.0.3.0/24"
  display_name      = "alephium_db_subnet"
  dns_label         = "db"
  security_list_ids = [oci_core_security_list.alephium_db_sl.id]
}