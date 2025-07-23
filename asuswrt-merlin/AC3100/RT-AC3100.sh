#!/bin/sh
#### Info #########################################################
#                          RT-AC3100 (Merlin)
#
# eth0      Physical port WAN (trunk for VLAN1/VLAN2)
# eth1      Physical port LAN 1
# eth2      Physical port LAN 2
# eth3      Physical port LAN 3
# eth4      Physical port LAN 4
#
# eth6      WiFi 2.4GHz (wl0)
# eth7      WiFi 5GHz (wl1)
#
# vlan1     LAN network (bridged)
# vlan2     WAN network (bridged or tagged)
#
# wl0.1     WiFi 2.4GHz guest1
# wl0.2     WiFi 2.4GHz guest2
#
# wl1.1     WiFi 5GHz guest1
###################################################################

# VLAN IDs
vlan_main=20       # HAL-9000 (Main)
vlan_iot=30        # HAL-8000 (IoT)
vlan_guest=60      # HAL-Guest (Guest)

# Interfaces
taggedPort="eth0"
mainSSIDs="wl1.1"
iotSSIDs="wl0.1"
guestSSIDs="wl0.2"
otherPorts="eth1 eth2 eth3 eth4 eth6 eth7"

# Cleanup: Remove interfaces from br0
brctl delif br0 ${taggedPort}
brctl delif br0 ${mainSSIDs} ${iotSSIDs} ${guestSSIDs}

# Create VLAN tags on trunk port
ip link add link ${taggedPort} name ${taggedPort}.${vlan_main} type vlan id ${vlan_main}
ip link add link ${taggedPort} name ${taggedPort}.${vlan_iot} type vlan id ${vlan_iot}
ip link add link ${taggedPort} name ${taggedPort}.${vlan_guest} type vlan id ${vlan_guest}
ip link set ${taggedPort}.${vlan_main} up
ip link set ${taggedPort}.${vlan_iot} up
ip link set ${taggedPort}.${vlan_guest} up

# HAL-9000 Main VLAN bridge
brctl addif br0 ${taggedPort}.${vlan_main}
brctl addif br0 ${mainSSIDs}
nvram set lan_ifnames="${otherPorts} ${taggedPort}.${vlan_main} ${mainSSIDs}"
nvram set br0_ifnames="${otherPorts} ${taggedPort}.${vlan_main} ${mainSSIDs}"
nvram set lan_ifname="br0"
nvram set br0_ifname="br0"

# HAL-8000 IoT VLAN bridge
brctl addbr br1
brctl addif br1 ${taggedPort}.${vlan_iot}
brctl addif br1 ${iotSSIDs}
ip link set br1 up
nvram set lan1_ifnames="${iotSSIDs} ${taggedPort}.${vlan_iot}"
nvram set br1_ifnames="${iotSSIDs} ${taggedPort}.${vlan_iot}"
nvram set lan1_ifname="br1"
nvram set br1_ifname="br1"

# HAL-Guest VLAN bridge
brctl addbr br2
brctl addif br2 ${taggedPort}.${vlan_guest}
brctl addif br2 ${guestSSIDs}
ip link set br2 up
nvram set lan2_ifnames="${guestSSIDs} ${taggedPort}.${vlan_guest}"
nvram set br2_ifnames="${guestSSIDs} ${taggedPort}.${vlan_guest}"
nvram set lan2_ifname="br2"
nvram set br2_ifname="br2"

# Enable AP isolation for HAL-Guest only
if ifconfig "${guestSSIDs}" >/dev/null 2>&1; then
  nvram set ${guestSSIDs}_ap_isolate=1
  wl -i ${guestSSIDs} ap_isolate 1
fi

# Declare wireless interfaces for system tracking (GUI visibility)
nvram set wl_ifnames="wl0 wl1 wl0.1 wl0.2 wl1.1"
nvram commit

# Restart wireless daemon
killall eapd 2>/dev/null || true
eapd
