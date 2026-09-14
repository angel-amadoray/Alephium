resource "oci_identity_dynamic_group" "alephium_instances" {
  compartment_id = var.tenancy_ocid
  name           = "alephium_instances_dg"
  description    = "Dynamic group for alephium instances"
  matching_rule  = "instance.compartment.id = '${var.compartment_ocid}'"
}

resource "oci_identity_policy" "alephium_object_storage_policy" {
  compartment_id = var.compartment_ocid
  name           = "alephium_media_policy"
  description    = "Allow instances to access media bucket"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.alephium_instances.name} to manage objects in compartment id ${var.compartment_ocid} where target.bucket.name = '${oci_objectstorage_bucket.bucket.name}'",
    "Allow dynamic-group ${oci_identity_dynamic_group.alephium_instances.name} to inspect buckets in compartment id ${var.compartment_ocid}"
  ]
}
