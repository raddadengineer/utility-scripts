#### Info #########################################################
#                            GT-AX11000
#
# eth0      Physical port WAN (can be VLAN trunk)
# eth1      Physical port LAN 1
# eth2      Physical port LAN 2
# eth3      Physical port LAN 3
# eth4      Physical port LAN 4
# eth5      Physical port 2.5G Gaming LAN
#
# eth6      WiFi 2.4GHz (wl0)
# eth7      WiFi 5GHz #1 (wl1)
# eth8      WiFi 5GHz #2 / Backhaul (wl2)
#
# wl0.1     WiFi 2.4GHz guest1
# wl0.2     WiFi 2.4GHz guest2
# wl0.3     WiFi 2.4GHz guest3
# wl0.4     WiFi 2.4GHz guest4
#
# wl1.1     WiFi 5GHz #1 guest1
# wl1.2     WiFi 5GHz #1 guest2
# wl1.3     WiFi 5GHz #1 guest3
#
# wl2.1     WiFi 5GHz #2 guest1
# wl2.2     WiFi 5GHz #2 guest2
# wl2.3     WiFi 5GHz #2 guest3
###################################################################
#!/bin/sh

# Wait for core radios to initialize
for iface in wl0 wl1 wl2; do
  while ! ifconfig "$iface" >/dev/null 2>&1; do
    logger "VLAN Bridge: Waiting for $iface to initialize..."
    sleep 2
  done
done

# VLAN IDs
vlan_main=20
vlan_iot=30
vlan_guest=60
vlan_gaming=40

# Interfaces
taggedPort="eth0"
otherPorts="eth1 eth2 eth3 eth4 eth5"

# SSID to bridge mappings
mainSSIDs="wl1"
gamingSSIDs="wl2"
iotSSIDs="wl0"
guestSSIDs="wl0.1"

wifi_eth_main="eth7"
wifi_eth_gaming="eth8"
wifi_eth_iot="eth6"

# Cleanup br0 safely
for iface in ${taggedPort} ${mainSSIDs} ${gamingSSIDs} ${iotSSIDs} ${guestSSIDs} \
             ${wifi_eth_main} ${wifi_eth_gaming} ${wifi_eth_iot}; do
  if ifconfig "$iface" >/dev/null 2>&1; then
    brctl delif br0 "$iface"
  fi
done

# Create VLAN subinterfaces
for vlan in ${vlan_main} ${vlan_iot} ${vlan_guest} ${vlan_gaming}; do
  ip link add link ${taggedPort} name ${taggedPort}.${vlan} type vlan id ${vlan}
  ip link set ${taggedPort}.${vlan} up
done

# Helper: safe add to bridge
add_to_bridge() {
  bridge=$1
  shift
  for iface in "$@"; do
    if ifconfig "$iface" >/dev/null 2>&1; then
      brctl addif "$bridge" "$iface"
    fi
  done
}

# br0 - HAL-9000 (Main)
add_to_bridge br0 ${taggedPort}.${vlan_main} ${mainSSIDs} ${wifi_eth_main}
nvram set lan_ifnames="${otherPorts} ${taggedPort}.${vlan_main} ${mainSSIDs} ${wifi_eth_main}"
nvram set br0_ifnames="${otherPorts} ${taggedPort}.${vlan_main} ${mainSSIDs} ${wifi_eth_main}"
nvram set lan_ifname="br0"
nvram set br0_ifname="br0"

# br1 - HAL-8000 (IoT)
brctl addbr br1
add_to_bridge br1 ${taggedPort}.${vlan_iot} ${iotSSIDs} ${wifi_eth_iot}
ip link set br1 up
nvram set lan1_ifnames="${taggedPort}.${vlan_iot} ${iotSSIDs} ${wifi_eth_iot}"
nvram set br1_ifnames="${taggedPort}.${vlan_iot} ${iotSSIDs} ${wifi_eth_iot}"
nvram set lan1_ifname="br1"
nvram set br1_ifname="br1"

# br2 - HAL-Guest
brctl addbr br2
add_to_bridge br2 ${taggedPort}.${vlan_guest} ${guestSSIDs}
ip link set br2 up
nvram set lan2_ifnames="${guestSSIDs} ${taggedPort}.${vlan_guest}"
nvram set br2_ifnames="${guestSSIDs} ${taggedPort}.${vlan_guest}"
nvram set lan2_ifname="br2"
nvram set br2_ifname="br2"

# br3 - HAL-9001 (Gaming)
brctl addbr br3
add_to_bridge br3 ${taggedPort}.${vlan_gaming} ${gamingSSIDs} ${wifi_eth_gaming}
ip link set br3 up
nvram set lan3_ifnames="${gamingSSIDs} ${wifi_eth_gaming} ${taggedPort}.${vlan_gaming}"
nvram set br3_ifnames="${gamingSSIDs} ${wifi_eth_gaming} ${taggedPort}.${vlan_gaming}"
nvram set lan3_ifname="br3"
nvram set br3_ifname="br3"

# Declare wireless interfaces (only ones that exist)
wl_declare=""
for iface in wl0 wl1 wl2 wl0.1; do
  if ifconfig "$iface" >/dev/null 2>&1; then
    wl_declare="$wl_declare $iface"
  fi
done
nvram set wl_ifnames="$wl_declare"
nvram commit

# Restart wireless daemon
killall eapd 2>/dev/null || true
eapd
