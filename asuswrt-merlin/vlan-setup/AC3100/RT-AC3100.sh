#!/bin/sh

# ------------------------------------------------------------------------------
# VLAN Setup & NVRAM Update Script for Asus RT-AC3100 (Asuswrt-Merlin)
# Optimized for VLAN-tagged SSIDs with uplink on eth0.
# ------------------------------------------------------------------------------
# SSID-to-VLAN Mapping:
#   HAL-8000  -> VLAN 30 -> br30 -> eth0.30 + wl0.1
#   HAL-9000  -> VLAN 40 -> br40 -> eth0.40 + wl1.1
#   HAL-Guest -> VLAN 60 -> br60 -> eth0.60 + wl0.2
# ------------------------------------------------------------------------------

echo "🔧 Starting fresh VLAN and NVRAM setup..."

# Detach wireless interfaces from br0
for iface in wl0.1 wl0.2 wl1.1; do
  brctl delif br0 "$iface" 2>/dev/null
done

# Cleanup existing VLAN interfaces on eth0
for vlan in 30 40 60; do
  if ip link show eth0.$vlan >/dev/null 2>&1; then
    echo "🧹 Deleting existing VLAN interface eth0.$vlan"
    ip link delete eth0.$vlan
  fi
done

# Cleanup old bridges
for br in br30 br40 br60; do
  if ip link show "$br" >/dev/null 2>&1; then
    echo "🧹 Deleting existing bridge $br"
    ip link set "$br" down
    brctl delbr "$br"
  fi
done

# Create new VLAN interfaces on eth0
for vlan in 30 40 60; do
  echo "🛠 Creating eth0.$vlan for VLAN $vlan..."
  ip link add link eth0 name eth0.$vlan type vlan id $vlan
  ip link set eth0.$vlan up
done

# Create new bridges and enable STP
for br in br30 br40 br60; do
  echo "🔗 Creating bridge $br and enabling STP..."
  brctl addbr "$br"
  brctl stp "$br" on
  ip link set "$br" up
done

# Enable STP on br0 if it exists
if ip link show br0 >/dev/null 2>&1; then
  echo "🔗 Enabling STP on br0..."
  brctl stp br0 on
fi

# Add VLAN interfaces to bridges
brctl addif br30 eth0.30
brctl addif br40 eth0.40
brctl addif br60 eth0.60

# Map AP SSIDs (wireless interfaces) to bridges
brctl addif br30 wl0.1      # HAL-8000
brctl addif br40 wl1.1      # HAL-9000
brctl addif br60 wl0.2      # HAL-Guest

echo "✅ All bridges and VLANs are now active and mapped with STP enabled."

# Update NVRAM with bridge mappings
nvram set vlan30_ifname="br30"
nvram set vlan40_ifname="br40"
nvram set vlan60_ifname="br60"

nvram set br30_ifnames="eth0.30 wl0.1"
nvram set br40_ifnames="eth0.40 wl1.1"
nvram set br60_ifnames="eth0.60 wl0.2"

nvram commit
echo "🧠 NVRAM committed with bridge mappings."

# Restart wireless daemon
killall eapd
eapd

echo "🎉 VLAN setup finalized with STP active on all bridges."
