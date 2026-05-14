# Changelog

## [Unreleased]

### Added
- Initial Terraform configuration for Proxmox VE deployment
- `bpg/proxmox` provider, Ubuntu 22.04 cloud-init VM
- Same `install_openclaw.sh` pattern as `openclaw_oracle` (Ubuntu/apt variant)
- Validate-only GitHub Actions workflow (no auto-apply)
- Identical output set to `openclaw_oracle`: `instance_id`, `instance_public_ip`, `openclaw_url`, `ssh_command`
