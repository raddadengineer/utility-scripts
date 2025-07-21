# AiMesh VLAN Bridge Setup - Main Router (AX11000)

This script sets up VLAN interfaces and bridges them with corresponding guest Wi-Fi interfaces on the AX11000 (running Asuswrt-Merlin).

## 🛠️ Features
- VLAN 20 → wl0.1
- VLAN 30 → wl1.1
- VLAN 60 → wl0.2

## 📄 Files
- `aimesh-vlan-bridge.sh`: Main VLAN bridge script
- `services-start`: Boot hook to run script on startup

## 🚀 Installation (Main Router)
1. Enable JFFS and script support:
```sh
nvram set jffs2_on=1
nvram set jffs2_scripts=1
nvram commit
reboot
```

2. After reboot, copy the scripts:
```sh
scp aimesh-vlan-bridge.sh services-start user@router:/jffs/scripts/
chmod +x /jffs/scripts/*
```
