# ─── Cloud-init user data ──────────────────────────────────────────────────────
# Rendered install script is uploaded to the Proxmox snippets storage via SSH.
# The bpg provider handles the file transfer automatically.

resource "proxmox_virtual_environment_file" "user_data" {
  content_type = "snippets"
  datastore_id = var.proxmox_snippets_storage
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/scripts/install_openclaw.sh", {
      openclaw_version = var.openclaw_version
      domain_name      = var.domain_name
    })
    file_name = "openclaw-user-data-${var.vm_id}.sh"
  }
}

# ─── OpenClaw VM ───────────────────────────────────────────────────────────────

resource "proxmox_virtual_environment_vm" "openclaw" {
  name      = var.vm_name
  node_name = var.proxmox_node
  vm_id     = var.vm_id
  tags      = ["openclaw"]

  # Clone from an Ubuntu 22.04 cloud-init template.
  # See README for how to prepare the template on your Proxmox host.
  clone {
    vm_id   = var.vm_template_id
    full    = true
    retries = 3
  }

  agent {
    enabled = true  # qemu-guest-agent must be installed in the template
  }

  cpu {
    cores = var.vm_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.vm_memory_mb
  }

  disk {
    datastore_id = var.vm_disk_storage
    size         = var.vm_disk_size
    interface    = "scsi0"
    discard      = "on"
    ssd          = true
    file_format  = "raw"
  }

  network_device {
    bridge = var.vm_network_bridge
    model  = "virtio"
  }

  # Cloud-init configuration
  initialization {
    datastore_id = var.vm_disk_storage

    ip_config {
      ipv4 {
        address = var.vm_ip_address
        gateway = var.vm_ip_address == "dhcp" ? null : var.vm_gateway
      }
    }

    dns {
      servers = var.vm_dns_servers
    }

    user_account {
      keys     = [trimspace(file(var.ssh_public_key_path))]
      username = "ubuntu"
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data.id
  }

  lifecycle {
    # Ignore user_data changes after initial provision — re-run install manually if needed.
    ignore_changes = [initialization[0].user_data_file_id]
  }
}
