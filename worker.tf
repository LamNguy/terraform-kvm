resource "libvirt_volume" "worker_base_image" {
  for_each = var.worker_configuration
  name     = each.value.base_image_name
  source   = var.base_image
}

resource "libvirt_volume" "worker_volume" {
  for_each       = var.worker_configuration
  name           = each.value.volume_name
  pool           = each.value.storage_pool
  base_volume_id = libvirt_volume.worker_base_image[each.key].id
  format         = "qcow2"
  size           = each.value.volume_size
}


locals {
  ceph01 = flatten([
    for worker_name, worker_data in var.worker_configuration : {
          for id, data in worker_data.ceph01 : id=> data
    }
  ])
}

locals {
  ceph02 = flatten([
    for worker_name, worker_data in var.worker_configuration : {
          for id, data in worker_data.ceph02 : id=> data
    }
  ])
}


# { for disk in local.volumes: disk.name => disk}
resource "libvirt_volume" "ceph_volume_1" {
  for_each       = { for disk in local.ceph01: disk.uid => disk}
  name           = each.value.name
  pool           = each.value.pool
  format         = each.value.format
}

# { for disk in local.volumes: disk.name => disk}
resource "libvirt_volume" "ceph_volume_2" {
  for_each       = { for disk in local.ceph02: disk.uid => disk}
  name           = each.value.name
  pool           = each.value.pool
  format         = each.value.format
}

data "template_file" "worker_user_data" {
  for_each = var.worker_configuration
  template = file("${path.module}/${each.value.cloud_init_config}")
}

data "template_file" "worker_network_config" {
  for_each = var.worker_configuration
  template = file("${path.module}/${each.value.network_config}")
}

resource "libvirt_cloudinit_disk" "worker_commoninit" {
  for_each       = var.worker_configuration
  name           = each.value.cloud_init_iso_name
  user_data      = data.template_file.worker_user_data[each.key].rendered
  network_config = data.template_file.worker_network_config[each.key].rendered
  pool           = var.pool01
}

resource "libvirt_domain" "worker" {
  for_each = var.worker_configuration
  name     = each.value.vm_name
  memory   = each.value.ram
  vcpu     = each.value.vcpu

  cloudinit = libvirt_cloudinit_disk.worker_commoninit[each.key].id

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
    volume_id = libvirt_volume.worker_volume[each.key].id
  }

  disk {
      #volume_id = element(libvirt_volume.ceph_volume[each.key].*.id,1)
      volume_id = libvirt_volume.ceph_volume_1[each.key].id
  }

  disk {
      volume_id = libvirt_volume.ceph_volume_2[each.key].id
  }

  graphics {
    type           = "spice"
    listen_type    = "address"
    autoport       = true
    listen_address = "0.0.0.0"
  }
}

# for_each = { for host, values in var.hosts: host => values if values.volume }

