# openclaw_proxmox TODO

- [x] Test full plan/apply cycle against a real Proxmox instance
- [x] Verify qemu-guest-agent IP discovery works with the bpg provider
- [x] Add optional firewall rules resource (proxmox_virtual_environment_firewall_rules)
- [x] Consider adding a second NIC option for VLAN isolation

Issues Found

Cloud Init install script for openclaw did not work properly. Nither the option to install only the min requirements.
We need a off line script to install openclaw on the proxmox host. This script should be able to install the required dependencies and set up the environment for openclaw to run properly.
It should configure OpenRouter Key and default model.
Also it should configure tailscale setup, ready to run tailscale up when deploy complete.
Final result should be web access to openclaw using tailscale after deployment.
