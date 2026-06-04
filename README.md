# openclaw_proxmox

Terraform project to deploy a VM in **Proxmox VE** configured for **[OpenClaw](https://github.com/openclaw/openclaw)**.

This is the self-hosted alternative to [`openclaw_oracle`](https://github.com/lab86-work/openclaw_oracle) for operators running their own Proxmox hypervisor. Note that this project provisions the infrastructure; the installation of OpenClaw itself is left to the user.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Architecture](#architecture)
- [Prepare the Ubuntu template](#prepare-the-ubuntu-template)
- [Credentials setup](#credentials-setup)
- [Usage](#usage)
- [Outputs](#outputs)

---

## Prerequisites

| Tool | Minimum version |
|------|----------------|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | 1.5+ |
| Proxmox VE | 7.4+ |
| Ubuntu 26.04 (Resolute) cloud-init template on Proxmox | see below |

---

## Architecture

```
Proxmox VE host
 VM (Ubuntu 26.04 (Resolute), cloned from cloud-init template)
```

All resources are created inline — no external Terraform modules are used.

Provider: [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox/latest)

---

## Prepare the Ubuntu template

Run once on your Proxmox host before first `terraform apply`:

```bash
# Download Ubuntu 26.04 (Resolute) cloud image
wget https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img

# Install qemu-guest-agent in the image (required for IP discovery)
virt-customize -a resolute-server-cloudimg-amd64.img --install qemu-guest-agent

# Create a VM template
qm create 9000 --name ubuntu-2604-template --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9000 resolute-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --agent enabled=1

qm template 9000
```

Set `vm_template_id = 9000` in `terraform.tfvars` (or whatever ID you used).

---

## Credentials setup

1. Create a dedicated Proxmox API token:
   ```
   PVE UI → Datacenter → Permissions → API Tokens → Add
   User: terraform@pam
   Token name: openclaw
   Privilege Separation: unchecked (inherits user roles)
   ```

2. Grant the token sufficient permissions:
   ```bash
   pveum aclmod / -user terraform@pam -role PVEVMAdmin
   pveum aclmod /storage -user terraform@pam -role PVEDatastoreAdmin
   ```

3. Copy and fill in the vars file:
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   $EDITOR terraform/terraform.tfvars
   ```

> **Never commit `terraform.tfvars`** — it is excluded by `.gitignore`.  
> Apply runs locally from the [fam-operator](https://github.com/lab86-work/fam-operator) checkout, not from CI.

---

## Usage

```bash
cd terraform

# Initialise providers
terraform init -backend=false

# Preview the plan
terraform plan -state=<path/to/family.tfstate>

# Apply
terraform apply -state=<path/to/family.tfstate>

# Get outputs (IP address, SSH command, etc.)
terraform output
```

Or use `fam-cli` from [fam-operator](https://github.com/lab86-work/fam-operator):

```bash
fam provision --family alpha
```

---

## Manual OpenClaw Installation

After running Terraform and obtaining the `ssh_command`, SSH into the VM to perform the installation. You can follow the official [OpenClaw documentation](https://github.com/openclaw/openclaw) to install the necessary dependencies and the application.

---

## Outputs

| Output | Description |
|--------|-------------|
| `instance_id` | Proxmox VM ID |
| `instance_public_ip` | IP address of the VM |
| `ssh_command` | Ready-to-use SSH command |

---

## CHANGELOG

See [CHANGELOG.md](CHANGELOG.md).
