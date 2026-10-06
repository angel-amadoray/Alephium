# using oracle atp
resource "oci_database_autonomous_database" "alephium_db" {
  compartment_id              = var.compartment_ocid
  db_name                     = "alephiumdb"
  display_name                = "alephium_db"
  is_mtls_connection_required = false
  db_workload                 = "OLTP"
  is_free_tier                = true
  license_model               = "LICENSE_INCLUDED"
  subnet_id                   = oci_core_subnet.alephium_db_subnet.id
  whitelisted_ips = [
    oci_core_vcn.alephium_vcn.id,
    local.dev_public_ip
  ]
}

data "http" "dev_public_ip" {
  url = "https://api.ipify.org"

  request_headers = {
    Accept = "text/plain"
  }
}

locals {
  # Limpiamos el resultado (por si hay saltos de línea)
  dev_public_ip = trimspace(data.http.dev_public_ip.response_body)
}
