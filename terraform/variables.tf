# ─── Proxmox API ───────────────────────────────────────────────────────────────

variable "proxmox_api_url" {
  description = "URL of the Proxmox VE API endpoint, e.g. https://192.168.1.10:8006/"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token in the format user@realm!token_name=<secret>."
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS certificate verification for the Proxmox API. Set true only for self-signed certs in lab environments."
  type        = bool
  default     = false
}

variable "proxmox_node" {
  description = "Name of the Proxmox node where the VM will be created (shown in the PVE UI)."
  type        = string
  default     = "pve"
}

variable "proxmox_node_address" {
  description = "IP or hostname of the Proxmox node, used by the bpg provider for SSH file uploads."
  type        = string
}

variable "proxmox_ssh_user" {
  description = "SSH user on the Proxmox host for provider operations (usually root)."
  type        = string
  default     = "root"
}

variable "proxmox_snippets_storage" {
  description = "Proxmox storage pool that supports snippets content type (for cloud-init user data)."
  type        = string
  default     = "local"
}

# ─── VM clone source ───────────────────────────────────────────────────────────

variable "vm_template_id" {
  description = "Proxmox VM ID of the Ubuntu 22.04 cloud-init template to clone. See README for how to create one."
  type        = number
}

variable "vm_id" {
  description = "Proxmox VM ID for the new OpenClaw VM. Must be unique on the node."
  type        = number
  default     = 200
}

# ─── VM compute ────────────────────────────────────────────────────────────────

variable "vm_name" {
  description = "Name for the Proxmox VM."
  type        = string
  default     = "openclaw-vm"
}

variable "vm_cores" {
  description = "Number of vCPU cores."
  type        = number
  default     = 2
}

variable "vm_memory_mb" {
  description = "Memory in MiB."
  type        = number
  default     = 4096
}

variable "vm_disk_size" {
  description = "OS disk size in GiB."
  type        = number
  default     = 20
}

variable "vm_disk_storage" {
  description = "Proxmox storage pool where the VM disk will be created."
  type        = string
  default     = "local-lvm"
}

# ─── networking VM ──────────────────────────

variable "vm_network_bridge" {
  description = "Proxmox bridge to attach the VM NIC to (e.g. vmbr0)."
  type        = string
  default     = "vmbr0"
}

variable "vm_ip_address" {
  description = "Static IP in CIDR notation (e.g. 192.168.1.100/24) or 'dhcp'."
  type        = string
  default     = "dhcp"
}

variable "vm_gateway" {
  description = "Default gateway IP. Required when vm_ip_address is a static CIDR."
  type        = string
  default     = ""
}

variable "vm_dns_servers" {
  description = "DNS servers injected via cloud-init."
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
}

# ─── SSH ───────────────────────────────────────────────────────────────────────

variable "ssh_public_key_path" {
  description = "Local filesystem path to the SSH public key for VM access."
  type        = string
}

variable "ssh_ingress_cidr" {
  description = "Source CIDR allowed to reach port 22. Used for documentation/firewall reference — Proxmox does not manage guest firewalls by default."
  type        = string

  validation {
    condition     = var.ssh_ingress_cidr != "0.0.0.0/0"
    error_message = "ssh_ingress_cidr must be a specific operator IP/CIDR, not 0.0.0.0/0."
  }
}

OpenClaw # ─── ───────────────────

variable "openclaw_version" {
  description = "openclaw/openclaw git ref to install (branch, tag, or SHA). Leave empty for main."
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Public domain name for the VM (e.g. fam.lab86.work). Required for HTTPS/Let's Encrypt. WhatsApp webhooks require HTTPS."
  type        = string
  default     = ""
}
