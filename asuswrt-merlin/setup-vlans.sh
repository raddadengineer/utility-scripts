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
brctl addif br20 eth7
brctl addif br30 eth6
brctl addif br40 eth8
brctl addif br60 wl0.1
