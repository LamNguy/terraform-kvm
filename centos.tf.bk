
resource "libvirt_volume" "centos_volume" {
  name           = "centos-qcow2"
  pool           = var.pool01
  format         = "qcow2"
  size           = 107374182400
}

resource "libvirt_domain" "centos-k8s" {
  name   = var.centos_hostname
  memory = "8192"
  vcpu   = 8

  boot_device {
    dev = ["hd","cdrom", "network"]
  }
  network_interface {
    network_name = "public"
  }


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
    volume_id = libvirt_volume.centos_volume.id
  }

  disk {
    file = "/var/lib/libvirt/images/pool/CentOS-7-x86_64-DVD-1810.iso"
  }

  graphics {
    type           = "spice"
    listen_type    = "address"
    autoport       = true
    listen_address = "0.0.0.0"
  }

}

