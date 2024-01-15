terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}


provider "libvirt" {
  uri = "qemu:///system"
}

variable "pool01" {
  default = "pool01"
}

variable "libvirt_disk_path" {
  description = "path for libvirt pool"
  default     = "/var/lib/libvirt/images/pool"
}

variable "ubuntu_18_img_url" {
  description = "ubuntu 18.04 image"
  default     = "http://cloud-images.ubuntu.com/releases/bionic/release-20191008/ubuntu-18.04-server-cloudimg-amd64.img"
}


variable "ssh_username" {
  description = "the ssh user to use"
  default     = "cloud"
}

variable "ssh_private_key" {
  description = "the private key to use"
  default     = "/root/.ssh/terraform"
}

variable "centos_hostname" {
  description = "centos hostname"
  default     = "centos"
}

variable "base_image" {
  description = "Base CentOS Cloud Image"
  default     = "/var/lib/libvirt/images/pool/CentOS-7-Cloud.qcow2"
  type        = string
}

variable "master_configuration" {
  description = "Map of Master node configuration."
  type        = map(any)

  default = {
    master01 = {
      vm_name             = "master01-k8s",
      vcpu                = 8,
      ram                 = 8192,
      volume_size         = 107374182400,
      network             = "public",
      base_image_name     = "master01-k8s-baseimage",
      volume_name         = "master01-k8s",
      cloud_init_config   = "config/cloud_init_master01.yml",
      network_config      = "config/network_config_master01.yml",
      cloud_init_iso_name = "commoninit-master01"

    },
    master02 = {
      vm_name             = "master02-k8s",
      vcpu                = 8,
      ram                 = 8192,
      volume_size         = 107374182400,
      network             = "public",
      base_image_name     = "master02-k8s-baseimage",
      volume_name         = "master02-k8s"
      cloud_init_config   = "config/cloud_init_master02.yml",
      network_config      = "config/network_config_master02.yml",
      cloud_init_iso_name = "commoninit-master02"
    },
    master03 = {
      vm_name             = "master03-k8s",
      vcpu                = 8,
      ram                 = 8192,
      volume_size         = 107374182400,
      network             = "public",
      base_image_name     = "master03-k8s-baseimage",
      volume_name         = "master03-k8s"
      cloud_init_config   = "config/cloud_init_master03.yml",
      network_config      = "config/network_config_master03.yml"
      cloud_init_iso_name = "commoninit-master03"
    }
  }
}

variable "worker_configuration" {
  description = "Map of Master node configuration."
  type        = map(any)

  default = {
    worker01 = {
      vm_name             = "worker01-k8s",
      vcpu                = 8,
      ram                 = 8192,
      storage_pool        = "pool01",
      volume_size         = 107374182400,
      network             = "public",
      base_image_name     = "worker01-k8s-baseimage",
      volume_name         = "worker01-k8s",
      cloud_init_config   = "config/cloud_init_worker01.yml",
      network_config      = "config/network_config_worker01.yml",
      cloud_init_iso_name = "commoninit-worker01",
      ceph01 = {
          uid = "worker01"
          name   = "worker01-ceph01-qcow2",
          pool   = "pool01",
          format = "qcow2",
          size   = 107374182400
        },
      ceph02 = {
          uid = "worker01"
          name   = "worker01-ceph02-qcow2",
          pool   = "pool01",
          format = "qcow2",
          size   = 107374182400
      }

    },
    worker02 = {
      vm_name             = "worker02-k8s",
      vcpu                = 8,
      ram                 = 8192,
      storage_pool        = "pool01",
      volume_size         = 107374182400,
      network             = "public",
      base_image_name     = "worker02-k8s-baseimage",
      volume_name         = "worker02-k8s"
      cloud_init_config   = "config/cloud_init_worker02.yml",
      network_config      = "config/network_config_worker02.yml",
      cloud_init_iso_name = "commoninit-worker02",
      ceph01 = {
          uid = "worker02"
          name   = "worker02-ceph01-qcow2",
          pool   = "pool01",
          format = "qcow2",
          size   = 107374182400
       },
       ceph02 = {
          uid = "worker02"
          name   = "worker02-ceph02-qcow2",
          pool   = "pool01",
          format = "qcow2",
          size   = 107374182400
       }
    },
    worker03 = {
      vm_name             = "worker03-k8s",
      vcpu                = 8,
      ram                 = 8192,
      storage_pool        = "pool01",
      volume_size         = 107374182400,
      network             = "public",
      base_image_name     = "worker03-k8s-baseimage",
      volume_name         = "worker03-k8s"
      cloud_init_config   = "config/cloud_init_worker03.yml",
      network_config      = "config/network_config_worker03.yml"
      cloud_init_iso_name = "commoninit-worker03",
      ceph01 = {
          uid = "worker03"
          name   = "worker03-ceph01-qcow2",
          pool   = "pool01"
          format = "qcow2",
          size   = 107374182400
      },
      ceph02 = {
          uid = "worker03"
          name   = "worker03-ceph02-qcow2",
          pool   = "pool01",
          format = "qcow2",
          size   = 107374182400
      }
    }
  }
}

