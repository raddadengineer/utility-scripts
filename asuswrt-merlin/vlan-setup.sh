#!/bin/sh

# Remove wireless and eth interfaces from default br0 bridge (ignore errors)
for i in eth6 eth7 eth8 wl0.1; do
  brctl delif br0 $i 2>/dev/null
done

# Create VLAN interfaces on eth0 if they don't exist
for vlan in 1 30 40 60; do
  ip link add link eth0 name eth0.$vlan type vlan id $vlan 2>/dev/null
  ip link set eth0.$vlan up
done

# Create bridges if not present and bring them up
for br in br1 br30 br40 br60; do
  brctl addbr $br 2>/dev/null
  ip link set $br up
done

# Add VLAN interfaces to respective bridges
brctl addif br1 eth0.1
brctl addif br30 eth0.30
brctl addif br40 eth0.40
brctl addif br60 eth0.60

# Add physical/wireless interfaces to corresponding bridges
brctl addif br1 eth7        # HAL-9000 VLAN 1
brctl addif br30 eth6       # HAL-8000 VLAN 30
brctl addif br40 eth8       # HAL-9001 VLAN 40
brctl addif br60 wl0.1      # HAL-Guest VLAN 60
