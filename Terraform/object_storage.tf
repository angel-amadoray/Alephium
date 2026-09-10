data "oci_objectstorage_namespace" "ns" {
    compartment_id = var.compartment_ocid
}

resource "oci_objectstorage_bucket" "bucket" {
    compartment_id = var.compartment_ocid
    namespace = data.oci_objectstorage_namespace.ns.namespace
    name = "alephium-media"
    access_type = "Private"
    storage_tier = "Standard"
}
