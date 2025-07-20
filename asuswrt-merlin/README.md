# Asuswrt-Merlin VLAN Bridge Script

This script configures VLAN-based bridging for Asus routers running Asuswrt-Merlin in **Access Point (AP) mode**. It assigns physical Ethernet ports and a guest Wi-Fi interface to separate VLANs and bridges.

## 🔧 Configuration Overview

| VLAN | Bridge | Interface(s)       | Purpose        |
|------|--------|--------------------|----------------|
| 20   | br20   | eth7               | HAL-9000       |
| 30   | br30   | eth6               | HAL-8000       |
| 40   | br40   | eth8               | HAL-9001       |
| 60   | br60   | wl0.1              | HAL-Guest Wi-Fi|

> All interfaces are removed from the default bridge `br0` and reassigned to VLAN-specific bridges.

## 📜 Script: `setup-vlans.sh`

```sh
#!/bin/sh

# Remove selected interfaces from the main bridge (br0)
for i in eth6 eth7 eth8 wl0.1; do
  brctl delif br0 $i 2>/dev/null
done

# Create VLAN subinterfaces on eth0
for vlan in 20 30 40 60; do
  ip link add link eth0 name eth0.$vlan type vlan id $vlan 2>/dev/null
  ip link set eth0.$vlan up
done

# Create VLAN-specific bridges
for br in br20 br30 br40 br60; do
  brctl addbr $br 2>/dev/null
  ip link set $br up
done

# Add VLAN subinterfaces to bridges
brctl addif br20 eth0.20
brctl addif br30 eth0.30
brctl addif br40 eth0.40
brctl addif br60 eth0.60

# Add physical ports/Wi-Fi to bridges
brctl addif br20 eth7       # HAL-9000 on VLAN 20
brctl addif br30 eth6       # HAL-8000 on VLAN 30
brctl addif br40 eth8       # HAL-9001 on VLAN 40
brctl addif br60 wl0.1      # HAL-Guest on VLAN 60
```

> ✅ Place this script in `/jffs/scripts/` and mark it executable:  
> `chmod +x /jffs/scripts/setup-vlans.sh`

---

## 🚀 Auto-Start on Boot

To apply the VLAN bridge config at boot, create `/jffs/scripts/services-start` with:

```sh
#!/bin/sh
/jffs/scripts/setup-vlans.sh
```

And mark it executable:

```sh
chmod +x /jffs/scripts/services-start
```

---

## 📝 Notes

- Make sure the switch/router feeding the AP supports VLAN trunking on the uplink (usually `eth0`).
- Interfaces in `br0` (eth0–eth5) can be reserved for management or main LAN if desired.
- Use `brctl show` to verify bridge mappings.

---

## 📡 Tested On

- Asus RT-AX86U with Asuswrt-Merlin (386.x / 388.x)
- AP Mode with trunked uplink on `eth0`
