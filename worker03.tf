resource "libvirt_volume" "worker03_centos07" {
  name   = "worker03_centos07"
  source = "/var/lib/libvirt/images/pool/CentOS-7-x86_64-GenericCloud.qcow2"
}

resource "libvirt_volume" "worker03_volume_1" {
  name           = "worker03-1-qcow2"
  pool           = var.pool01
  base_volume_id = libvirt_volume.worker03_centos07.id
  format         = "qcow2"
  size           = 107374182400
}

resource "libvirt_volume" "worker03_volume_2" {
  name   = "worker03-2-qcow2"
  pool   = var.pool01
  format = "qcow2"
  size   = 107374182400
}

resource "libvirt_volume" "worker03_volume_3" {
  name   = "worker03-3-qcow2"
  pool   = var.pool01
  format = "qcow2"
  size   = 107374182400
}




data "template_file" "user_data_worker03" {
  template = file("${path.module}/config/cloud_init_worker03.yml")
}

data "template_file" "network_config_worker03" {
  template = file("${path.module}/config/network_config_worker03.yml")
}

resource "libvirt_cloudinit_disk" "commoninit_worker03" {
  name           = "commoninit_worker03.iso"
  user_data      = data.template_file.user_data_worker03.rendered
  network_config = data.template_file.network_config_worker03.rendered
  pool           = var.pool01
}

resource "libvirt_domain" "worker03-k8s" {
  name   = var.worker03_hostname
  memory = "16384"
  vcpu   = 16

  cloudinit = libvirt_cloudinit_disk.commoninit_worker03.id

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
    volume_id = libvirt_volume.worker03_volume_1.id
  }

  disk {
    volume_id = libvirt_volume.worker03_volume_2.id
  }

  disk {
    volume_id = libvirt_volume.worker03_volume_3.id
  }

  graphics {
    type           = "spice"
    listen_type    = "address"
    autoport       = true
    listen_address = "0.0.0.0"
  }

}

