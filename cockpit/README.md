# 🚀 Cockpit Fleet Installer

Automate the deployment of [Cockpit](https://cockpit-project.org/) across a fleet of Linux systems. This Bash script helps streamline SSH key setup, Cockpit installation, and optional parallel execution — ideal for sysadmins and homelab enthusiasts.

---

## 🎛️ Features

- 🔑 SSH key distribution for passwordless login
- 🛠️ Cockpit installation with automatic distro detection (`apt` or `dnf`)
- 📄 Timestamped logging for each setup session
- 🧵 Parallel execution for faster deployment
- 🧩 Modular CLI flags for flexible control

---

## 📦 Requirements

- Bash shell
- SSH access and `sudo` privileges on all target hosts
- `ssh`, `ssh-copy-id`, and a public SSH key (`~/.ssh/id_ed25519.pub`)
- Target systems must use either APT (Debian/Ubuntu) or DNF (Fedora/RHEL/CentOS)

---

## ⚙️ Script Flags

| Flag            | Description                                  |
|-----------------|----------------------------------------------|
| `--keys-only`   | Deploy SSH keys only                         |
| `--install-only`| Install Cockpit only                         |
| `--parallel`    | Run Cockpit installs across hosts in parallel |

---

## 🧪 Usage Examples

```bash
./cockpit-fleet.sh                       # Deploy keys + install Cockpit
./cockpit-fleet.sh --keys-only          # Just distribute SSH keys
./cockpit-fleet.sh --install-only       # Just install Cockpit
./cockpit-fleet.sh --parallel           # Parallel Cockpit installs
```

---

## 📂 File Structure

```text
cockpit-fleet/
├── cockpit-fleet.sh            # Main deployment script
├── README.md                   # Documentation file
└── fleet-install-YYYYMMDD.log  # Timestamped logs from each run
```

---

## 🛡️ Error Handling & Logging

- Uses `set -e` in remote install block for safe fail-fast execution
- SSH has connection timeouts and skips unreachable hosts
- Logs each run to a timestamped `.log` file for auditing and troubleshooting

---

## 🔮 Future Enhancements

- Cloud-init support for Proxmox or other virtualization platforms
- Conversion into Ansible roles and inventory-based deployment
- VLAN-aware targeting and dynamic host provisioning
- Optional Cockpit extensions (e.g. `cockpit-podman`, `cockpit-machines`)
- Auto-enrollment of target hosts into centralized Cockpit dashboard

---

## 🧠 Pro Tips

- Use SSH key authentication to avoid repeated password prompts  
- Run `tail -f fleet-install-*.log` to monitor progress in real time  
- Validate `sudo` access on remote hosts before deployment  
- Test on a small group of hosts before rolling out fleet-wide

---

## 👨‍💻 Maintainer

**Author:**   
Infra automation specialist, Proxmox power-user, and homelab tinkerer.

Got feedback, feature requests, or ideas? Fork the script or reach out!
