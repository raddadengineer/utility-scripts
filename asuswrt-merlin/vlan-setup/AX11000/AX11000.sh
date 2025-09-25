#!/bin/sh

# ------------------------------------------------------------------------------
# VLAN Setup & NVRAM Update Script for Asus RT-AX11000 (Asuswrt-Merlin)
# Optimized for AP Mesh mode with VLAN-tagged SSIDs.
# ------------------------------------------------------------------------------
# SSID-to-VLAN Mapping:
#   HAL-9000  -> VLAN 20 -> br20 -> eth7
#   HAL-8000  -> VLAN 30 -> br30 -> eth6
#   HAL-9001  -> VLAN 40 -> br40 -> eth8
#   HAL-Guest -> VLAN 60 -> br60 -> wl0.1 + wl1.1 (if exists)
# ------------------------------------------------------------------------------

echo " Starting fresh VLAN and NVRAM setup..."

# Detach interfaces from br0
for iface in eth6 eth7 eth8 wl0.1 wl1.1; do
  brctl delif br0 "$iface" 2>/dev/null
done

# Cleanup existing VLAN interfaces on eth5
for vlan in 20 30 40 60; do
  if ip link show eth5.$vlan >/dev/null 2>&1; then
    echo " Deleting existing VLAN interface eth5.$vlan"
    ip link delete eth5.$vlan
  fi
done

# Cleanup old bridges
for br in br20 br30 br40 br60; do
  if ip link show "$br" >/dev/null 2>&1; then
    echo " Deleting existing bridge $br"
    ip link set "$br" down
    brctl delbr "$br"
  fi
done

# Create new VLAN interfaces on eth5
for vlan in 20 30 40 60; do
  echo " Creating eth5.$vlan for VLAN $vlan..."
  ip link add link eth5 name eth5.$vlan type vlan id $vlan
  ip link set eth5.$vlan up
done

# Create new bridges and enable STP
for br in br20 br30 br40 br60; do
  echo " Creating bridge $br and enabling STP..."
  brctl addbr "$br"
  brctl stp "$br" on
  ip link set "$br" up
done

# Enable STP on br0 if it exists
if ip link show br0 >/dev/null 2>&1; then
  echo " Enabling STP on br0..."
  brctl stp br0 on
fi

# Add VLAN interfaces to bridges
brctl addif br20 eth5.20
brctl addif br30 eth5.30
brctl addif br40 eth5.40
brctl addif br60 eth5.60

# Map AP SSIDs to bridges
brctl addif br20 eth7       # HAL-9000
brctl addif br30 eth6       # HAL-8000
brctl addif br40 eth8       # HAL-9001
brctl addif br60 wl0.1      # HAL-Guest (2.4GHz)

# Conditionally add wl1.1 if it exists
if ip link show wl1.1 >/dev/null 2>&1; then
  echo " Adding wl1.1 to br60"
  brctl addif br60 wl1.1
else
  echo " Interface wl1.1 not found, skipping"
fi

echo " All bridges and VLANs are now active and mapped with STP enabled."

# Update NVRAM with bridge mappings
nvram set vlan20_ifname="br20"
nvram set vlan30_ifname="br30"
nvram set vlan40_ifname="br40"
nvram set vlan60_ifname="br60"

nvram set br20_ifnames="eth5.20 eth7"
nvram set br30_ifnames="eth5.30 eth6"
nvram set br40_ifnames="eth5.40 eth8"
if ip link show wl1.1 >/dev/null 2>&1; then
  nvram set br60_ifnames="eth5.60 wl0.1 wl1.1"
else
  nvram set br60_ifnames="eth5.60 wl0.1"
fi

nvram commit
echo " NVRAM committed with bridge mappings."

# Restart wireless daemon
killall eapd
eapd

echo " VLAN setup finalized with STP active on all bridges."
