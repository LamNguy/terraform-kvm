resource "libvirt_volume" "master02_centos07" {
  name   = "master02_centos07"
  source = "/var/lib/libvirt/images/pool/CentOS-7-x86_64-GenericCloud.qcow2"
}

resource "libvirt_volume" "master02_volume" {
  name           = "master02-qcow2"
  pool           = var.pool01
  base_volume_id = libvirt_volume.master02_centos07.id
  format         = "qcow2"
  size           = 107374182400
}

data "template_file" "user_data_master02" {
  template = file("${path.module}/config/cloud_init_master02.yml")
}

data "template_file" "network_config_master02" {
  template = file("${path.module}/config/network_config_master02.yml")
}

resource "libvirt_cloudinit_disk" "commoninit_master02" {
  name           = "commoninit_master02.iso"
  user_data      = data.template_file.user_data_master02.rendered
  network_config = data.template_file.network_config_master02.rendered
  pool           = var.pool01
}

resource "libvirt_domain" "master02-k8s" {
  name   = var.master02_hostname
  memory = "8192"
  vcpu   = 8

  cloudinit = libvirt_cloudinit_disk.commoninit_master02.id

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
    volume_id = libvirt_volume.master02_volume.id
  }

  graphics {
    type           = "spice"
    listen_type    = "address"
    autoport       = true
    listen_address = "0.0.0.0"
  }

}

