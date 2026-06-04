# openclaw_proxmox TODO

- [x] Test full plan/apply cycle against a real Proxmox instance
- [x] Verify qemu-guest-agent IP discovery works with the bpg provider
- [x] Add optional firewall rules resource (proxmox_virtual_environment_firewall_rules)
- [x] Consider adding a second NIC option for VLAN isolation

## Issues Found & Required Fixes

The Cloud Init install script for openclaw did not work properly. We are going to simplify the install: Terraform will only be in charge of creating the VM, setting up SSH keys, and configuring basic VM settings (like networking/firewall). The installation of OpenClaw will be left up to the user.

### Tasks to Implement Fix:

- [ ] **Remove `install.sh` Integration from `compute.tf`**
  - Delete the `proxmox_virtual_environment_file.user_data` snippet resource that uploads the install script.
  - Remove the `vendor_data_file_id` (or `user_data_file_id`) parameter from the `initialization` block in the VM resource.
  - Remove the `ignore_changes` lifecycle hook for the data file ID.
- [ ] **Delete Unnecessary Files**
  - Remove `terraform/scripts/install.sh` and the `terraform/scripts/` directory entirely.
- [ ] **Clean Up Variables and Outputs**
  - In `variables.tf`: Remove variables strictly related to OpenClaw installation (e.g., `openclaw_version`, `domain_name`).
  - In `terraform.tfvars.example`: Remove the commented examples for the deleted variables.
  - In `outputs.tf`: Remove the `openclaw_url` output since the application won't be automatically installed.
- [ ] **Update Documentation**
  - In `README.md`: Remove claims of automatically installing OpenClaw via cloud-init.
  - In `README.md` (Architecture section): Remove Node.js, nginx, and OpenClaw systemd components from the Terraform-managed architecture summary.
  - In `README.md`: Add manual installation instructions for OpenClaw for users to follow after SSHing into the VM.
