resource "libvirt_volume" "worker02_centos07" {
  name   = "worker02_centos07"
  source = "/var/lib/libvirt/images/pool/CentOS-7-x86_64-GenericCloud.qcow2"
}

resource "libvirt_volume" "worker02_volume_1" {
  name           = "worker02-1-qcow2"
  pool           = var.pool01
  base_volume_id = libvirt_volume.worker02_centos07.id
  format         = "qcow2"
  size           = 107374182400
}

resource "libvirt_volume" "worker02_volume_2" {
  name   = "worker02-2-qcow2"
  pool   = var.pool01
  format = "qcow2"
  size   = 107374182400
}

resource "libvirt_volume" "worker02_volume_3" {
  name   = "worker02-3-qcow2"
  pool   = var.pool01
  format = "qcow2"
  size   = 107374182400
}




data "template_file" "user_data_worker02" {
  template = file("${path.module}/config/cloud_init_worker02.yml")
}

data "template_file" "network_config_worker02" {
  template = file("${path.module}/config/network_config_worker02.yml")
}

resource "libvirt_cloudinit_disk" "commoninit_worker02" {
  name           = "commoninit_worker02.iso"
  user_data      = data.template_file.user_data_worker02.rendered
  network_config = data.template_file.network_config_worker02.rendered
  pool           = var.pool01
}

resource "libvirt_domain" "worker02-k8s" {
  name   = var.worker02_hostname
  memory = "16384"
  vcpu   = 16

  cloudinit = libvirt_cloudinit_disk.commoninit_worker02.id

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
    volume_id = libvirt_volume.worker02_volume_1.id
  }

  disk {
    volume_id = libvirt_volume.worker02_volume_2.id
  }

  disk {
    volume_id = libvirt_volume.worker02_volume_3.id
  }

  graphics {
    type           = "spice"
    listen_type    = "address"
    autoport       = true
    listen_address = "0.0.0.0"
  }

}
