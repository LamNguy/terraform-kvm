resource "libvirt_volume" "master01_centos07" {
  name   = "master01_centos07"
  source = "/var/lib/libvirt/images/pool/CentOS-7-Cloud.qcow2"
}

resource "libvirt_volume" "master01_volume" {
  name           = "master01-qcow2"
  pool           = var.pool01
  base_volume_id = libvirt_volume.master01_centos07.id
  format         = "qcow2"
  size           = 107374182400
}

data "template_file" "user_data_master01" {
  template = file("${path.module}/config/cloud_init_master01.yml")
}

data "template_file" "network_config_master01" {
  template = file("${path.module}/config/network_config_master01.yml")
}

resource "libvirt_cloudinit_disk" "commoninit_master01" {
  name           = "commoninit_master01.iso"
  user_data      = data.template_file.user_data_master01.rendered
  network_config = data.template_file.network_config_master01.rendered
  pool           = var.pool01
}

resource "libvirt_domain" "master01-k8s" {
  name   = var.master01_hostname
  memory = "8192"
  vcpu   = 8

  cloudinit = libvirt_cloudinit_disk.commoninit_master01.id

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
    volume_id = libvirt_volume.master01_volume.id
  }

  graphics {
    type           = "spice"
    listen_type    = "address"
    autoport       = true
    listen_address = "0.0.0.0"
  }

}

