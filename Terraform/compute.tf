# oracle linux 8
data "oci_core_images" "ol8" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# obtain available ads
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# web instance
resource "oci_core_instance" "web_instance" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape               = "VM.Standard.A1.Flex"
  display_name        = "web_instance"

  create_vnic_details {
    subnet_id        = oci_core_subnet.alephium_web_subnet.id
    assign_public_ip = true
    display_name     = "web_instance_vnic"
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ol8.images[0].id
  }

  shape_config {
    memory_in_gbs = 12
    ocpus         = 2
  }

  # ssh key and initial script: todo
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(file("${path.module}/user_data/web_instance.sh"))
  }

  preserve_boot_volume = false
}

# app instance
resource "oci_core_instance" "app_instance" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape               = "VM.Standard.A1.Flex"
  display_name        = "app_instance"

  create_vnic_details {
    subnet_id        = oci_core_subnet.alephium_app_subnet.id
    assign_public_ip = false
    display_name     = "app_instance_vnic"
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ol8.images[0].id
  }

  shape_config {
    memory_in_gbs = 12
    ocpus         = 2
  }

  # ssh key and initial script: todo
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(file("${path.module}/user_data/app_instance.sh"))
  }

  preserve_boot_volume = false
}
