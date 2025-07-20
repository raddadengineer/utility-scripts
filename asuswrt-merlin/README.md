# 🧠 Asuswrt-Merlin VLAN Bridge Script

This script configures custom VLAN bridges on an **Asus router running Asuswrt-Merlin in Access Point (AP) mode**. It enables mapping of physical and virtual interfaces (like wireless SSIDs) to specific VLANs using standard Linux bridge utilities.

---

## 📦 VLAN Configuration Summary

| Name       | Interface | VLAN ID | Bridge | Purpose                  |
|------------|-----------|---------|--------|--------------------------|
| HAL-9001   | eth8      | 40      | br40   | High-priority wired device |
| HAL-9000   | eth7      | 1       | br1    | Default wired LAN        |
| HAL-8000   | eth6      | 30      | br30   | IoT devices              |
| HAL-Guest  | wl0.1     | 60      | br60   | Guest Wi-Fi SSID         |

---

## 🔧 Script Installation

1. **SSH into your Asus router** (must have Asuswrt-Merlin with JFFS enabled).
2. **Save the script** to:

   ```sh
   /jffs/scripts/vlan-setup.sh

---

## Make it executable:
 ```sh
chmod +x /jffs/scripts/vlan-setup.sh



## 🚀 Manual Execution: 
Run the script manually via SSH:

```sh
sh /jffs/scripts/vlan-setup.sh
