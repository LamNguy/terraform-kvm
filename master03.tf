resource "libvirt_volume" "master03_centos07" {
  name   = "master03_centos07"
  source = "/var/lib/libvirt/images/pool/CentOS-7-x86_64-GenericCloud.qcow2"
}

resource "libvirt_volume" "master03_volume" {
  name           = "master03-qcow2"
  pool           = var.pool01
  base_volume_id = libvirt_volume.master03_centos07.id
  format         = "qcow2"
  size           = 107374182400
}

data "template_file" "user_data_master03" {
  template = file("${path.module}/config/cloud_init_master03.yml")
}

data "template_file" "network_config_master03" {
  template = file("${path.module}/config/network_config_master03.yml")
}

resource "libvirt_cloudinit_disk" "commoninit_master03" {
  name           = "commoninit_master03.iso"
  user_data      = data.template_file.user_data_master03.rendered
  network_config = data.template_file.network_config_master03.rendered
  pool           = var.pool01
}

resource "libvirt_domain" "master03-k8s" {
  name   = var.master03_hostname
  memory = "8192"
  vcpu   = 8

  cloudinit = libvirt_cloudinit_disk.commoninit_master03.id

  network_interface {
    network_name = "public"
  }


  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.master03_volume.id
  }

  graphics {
    type           = "spice"
    listen_type    = "address"
    autoport       = true
    listen_address = "0.0.0.0"
  }

}

