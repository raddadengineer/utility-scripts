# AiMesh VLAN Bridge Setup - Node (AC3100)

This script enables VLAN bridging for guest Wi-Fi interfaces on AiMesh nodes (AC3100) in AP mode.

## 📄 Files
- `aimesh-vlan-bridge.sh`: VLAN bridge script
- `services-start`: Script launcher at boot

## 🛠️ Required After Factory Reset

Enable JFFS and script support on the node:
```sh
nvram set jffs2_on=1
nvram set jffs2_scripts=1
nvram commit
reboot
```

Then copy and activate scripts:
```sh
scp aimesh-vlan-bridge.sh services-start user@node:/jffs/scripts/
chmod +x /jffs/scripts/*
```
