output "web_instance_public_ip" {
  value = oci_core_instance.web_instance.public_ip
}

output "app_instance_private_ip" {
  value = oci_core_instance.app_instance.public_ip
}

output "bucket_name" {
  value = oci_objectstorage_bucket.bucket.name
}

output "bucket_namespace" {
  value = data.oci_objectstorage_namespace.ns.namespace
}
