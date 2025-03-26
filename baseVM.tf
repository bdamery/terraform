provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "_YOUR_DATACENTER_NAME"
}

data "vsphere_datastore" "datastore" {
  name          = "_YOUR_DATASTORE_NAME"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "_YOUR_RESOURCE_POOL_NAME_"  #Resources by default 
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "_YOUR_PORTGROUP_NAME_"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "_YOUR_TEMPLATE_NAME_"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name                       = var.name
  datastore_id               = data.vsphere_datastore.datastore.id
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  num_cpus                   = 2
  memory                     = 2048
  guest_id                   = "centos7_64Guest"
  wait_for_guest_net_timeout = -1
  network_interface {
    network_id = data.vsphere_network.network.id
  }
  disk {
    label = "disk0"
    size  = 20
  }
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    customize {
      linux_options {
        host_name = var.name
        domain    = "_YOUR_DOMAIN_NAME_"
      }
      network_interface {
        ipv4_address = var.ip
        ipv4_netmask = 24
      }
    }
  }
}
variable "vsphere_server" {
  type    = "string"
  default = "_VCENTER_FQDN_OR_IP_"
}

variable "vsphere_user" {
  type    = "string"
  default = "_VCENTER_USER_"
}

variable "vsphere_password" {
  type    = "string"
  default = "_VCENTER_PASSWORD_"
}

variable "name" {
  type    = "string"
  default = "test-1"
}

variable "ip" {
  type    = "string"
  default = "192.168.1.1"
}
