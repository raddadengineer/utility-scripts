#!/bin/sh
logger "Starting VLAN bridge setup"

# Remove guest interfaces from br0
for iface in wl0.1 wl0.2 wl1.1; do
  brctl delif br0 $iface 2>/dev/null
done

# Create VLANs
for vid in 20 30 60; do
  ip link add link eth0 name eth0.$vid type vlan id $vid
  ip link set eth0.$vid up
done

# Create bridges and add interfaces
brctl addbr br20
brctl addif br20 eth0.20
brctl addif br20 wl0.1

brctl addbr br30
brctl addif br30 eth0.30
brctl addif br30 wl1.1

brctl addbr br60
brctl addif br60 eth0.60
brctl addif br60 wl0.2

logger "VLAN bridge setup complete"
