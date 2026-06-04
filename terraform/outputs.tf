locals {
  # For static IPs strip the CIDR prefix; for DHCP read from guest agent.
  vm_ip = var.vm_ip_address == "dhcp" ? (
    try(proxmox_virtual_environment_vm.openclaw.ipv4_addresses[1][0], "dhcp-pending")
  ) : split("/", var.vm_ip_address)[0]
}

output "instance_id" {
  description = "Proxmox VM ID of the OpenClaw instance."
  value       = proxmox_virtual_environment_vm.openclaw.vm_id
}

output "instance_public_ip" {
  description = "IP address of the OpenClaw VM."
  value       = local.vm_ip
}


output "ssh_command" {
  description = "SSH command to connect to the VM."
  value       = "ssh ubuntu@${local.vm_ip}"
}
