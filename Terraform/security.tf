# security lists

# web security list (allows http, https, ssh) 
resource "oci_core_security_list" "alephium_web_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.alephium_vcn.id
  display_name   = "alephium_web_sl"

  # http
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 80
      max = 80
    }
  }

  # https
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }

  # ssh
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

# app security list (only from the app subnet)
resource "oci_core_security_list" "alephium_app_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.alephium_vcn.id
  display_name   = "alephium_app_sl"

  ingress_security_rules {
    protocol    = "6"
    source      = "10.0.1.0/24" # only from web subnet
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 8000
      max = 8000
    }
  }

  # ssh from web
  ingress_security_rules {
    protocol = "6"
    source   = "10.0.1.0/24"
    tcp_options {
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

# db security list (only from the app subnet)
resource "oci_core_security_list" "alephium_db_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.alephium_vcn.id
  display_name   = "alephium_db_sl"

  ingress_security_rules {
    protocol    = "6"
    source      = "10.0.2.0/24" # only from app subnet
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 1522
      max = 1522
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}
