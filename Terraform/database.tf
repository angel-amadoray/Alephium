# using oracle atp
resource "oci_database_autonomous_database" "alephium_db" {
  compartment_id = var.compartment_ocid
  db_name        = "alephiumdb"
  display_name   = "alephium_atp"
  admin_password = var.db_password
  db_workload    = "OLTP"
  is_free_tier   = true
  license_model  = "LICENSE_INCLUDED"
  subnet_id      = oci_core_subnet.alephium_db_subnet.id
}
