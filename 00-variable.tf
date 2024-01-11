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

variable "master01_hostname" {
  description = "vm hostname"
  default     = "master01-k8s"
}


variable "master02_hostname" {
  description = "vm hostname"
  default     = "master02-k8s"
}

variable "master03_hostname" {
  description = "vm hostname"
  default     = "master03-k8s"
}

variable "worker01_hostname" {
  description = "vm hostname"
  default     = "worker01-k8s"
}

variable "worker02_hostname" {
  description = "vm hostname"
  default     = "worker02-k8s"
}


variable "worker03_hostname" {
  description = "vm hostname"
  default     = "worker03-k8s"
}

variable "centos_hostname" {
  description = "centos hostname"
  default     = "centos-k8s"
}

