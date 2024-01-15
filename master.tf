resource "libvirt_volume" "base_image" {
  for_each = var.master_configuration
  name     = each.value.base_image_name
  source   = var.base_image
}

resource "libvirt_volume" "master_volume" {
  for_each       = var.master_configuration
  name           = each.value.volume_name
  pool           = var.pool01
  base_volume_id = libvirt_volume.base_image[each.key].id
  format         = "qcow2"
  size           = each.value.volume_size
}

data "template_file" "user_data" {
  for_each = var.master_configuration
  template = file("${path.module}/${each.value.cloud_init_config}")
}

data "template_file" "network_config" {
  for_each = var.master_configuration
  template = file("${path.module}/${each.value.network_config}")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  for_each       = var.master_configuration
  name           = each.value.cloud_init_iso_name
  user_data      = data.template_file.user_data[each.key].rendered
  network_config = data.template_file.network_config[each.key].rendered
  pool           = var.pool01
}

resource "libvirt_domain" "master" {
  for_each = var.master_configuration
  name     = each.value.vm_name
  memory   = each.value.ram
  vcpu     = each.value.vcpu

  cloudinit = libvirt_cloudinit_disk.commoninit[each.key].id

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
    volume_id = libvirt_volume.master_volume[each.key].id
  }

  graphics {
    type           = "spice"
    listen_type    = "address"
    autoport       = true
    listen_address = "0.0.0.0"
  }
}

