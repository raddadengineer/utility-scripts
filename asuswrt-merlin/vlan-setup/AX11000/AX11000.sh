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

# VLAN IDs
vlan_main=20
vlan_iot=30
vlan_guest=60
vlan_gaming=40

# Interfaces
taggedPort="eth0"

mainSSIDs="wl1"
gamingSSIDs="wl2"
iotSSIDs="wl0"
guestSSIDs="wl0.1"

wifi_eth_main="eth7"
wifi_eth_gaming="eth8"
wifi_eth_iot="eth6"

otherPorts="eth1 eth2 eth3 eth4 eth5"
allWiFiAliases="${wifi_eth_main} ${wifi_eth_gaming} ${wifi_eth_iot}"
allSSIDs="${mainSSIDs} ${gamingSSIDs} ${iotSSIDs} ${guestSSIDs}"

# ----------------------------------------------------
# 🧼 Clean default bridge
# ----------------------------------------------------
for iface in ${taggedPort} ${allSSIDs} ${allWiFiAliases}; do
  brctl delif br0 $iface
done

# ----------------------------------------------------
# 🌐 Create VLAN trunk tags
# ----------------------------------------------------
ip link add link ${taggedPort} name ${taggedPort}.${vlan_main} type vlan id ${vlan_main}
ip link add link ${taggedPort} name ${taggedPort}.${vlan_iot} type vlan id ${vlan_iot}
ip link add link ${taggedPort} name ${taggedPort}.${vlan_guest} type vlan id ${vlan_guest}
ip link add link ${taggedPort} name ${taggedPort}.${vlan_gaming} type vlan id ${vlan_gaming}
ip link set ${taggedPort}.${vlan_main} up
ip link set ${taggedPort}.${vlan_iot} up
ip link set ${taggedPort}.${vlan_guest} up
ip link set ${taggedPort}.${vlan_gaming} up

# ----------------------------------------------------
# 🏠 br0 - HAL-9000 Main VLAN
# ----------------------------------------------------
brctl addif br0 ${taggedPort}.${vlan_main}
brctl addif br0 ${mainSSIDs}
brctl addif br0 ${wifi_eth_main}
nvram set lan_ifnames="${otherPorts} ${taggedPort}.${vlan_main} ${mainSSIDs} ${wifi_eth_main}"
nvram set br0_ifnames="${otherPorts} ${taggedPort}.${vlan_main} ${mainSSIDs} ${wifi_eth_main}"
nvram set lan_ifname="br0"
nvram set br0_ifname="br0"

# ----------------------------------------------------
# 🧪 br1 - HAL-8000 IoT VLAN
# ----------------------------------------------------
brctl addbr br1
brctl addif br1 ${taggedPort}.${vlan_iot}
brctl addif br1 ${iotSSIDs}
brctl addif br1 ${wifi_eth_iot}
ip link set br1 up
nvram set lan1_ifnames="${taggedPort}.${vlan_iot} ${iotSSIDs} ${wifi_eth_iot}"
nvram set br1_ifnames="${taggedPort}.${vlan_iot} ${iotSSIDs} ${wifi_eth_iot}"
nvram set lan1_ifname="br1"
nvram set br1_ifname="br1"

# ----------------------------------------------------
# 🚪 br2 - HAL-Guest VLAN
# ----------------------------------------------------
brctl addbr br2
brctl addif br2 ${taggedPort}.${vlan_guest}
brctl addif br2 ${guestSSIDs}
ip link set br2 up
nvram set lan2_ifnames="${guestSSIDs} ${taggedPort}.${vlan_guest}"
nvram set br2_ifnames="${guestSSIDs} ${taggedPort}.${vlan_guest}"
nvram set lan2_ifname="br2"
nvram set br2_ifname="br2"

# ----------------------------------------------------
# 🎮 br3 - HAL-9001 Gaming VLAN
# ----------------------------------------------------
brctl addbr br3
brctl addif br3 ${taggedPort}.${vlan_gaming}
brctl addif br3 ${gamingSSIDs}
brctl addif br3 ${wifi_eth_gaming}
ip link set br3 up
nvram set lan3_ifnames="${gamingSSIDs} ${wifi_eth_gaming} ${taggedPort}.${vlan_gaming}"
nvram set br3_ifnames="${gamingSSIDs} ${wifi_eth_gaming} ${taggedPort}.${vlan_gaming}"
nvram set lan3_ifname="br3"
nvram set br3_ifname="br3"

# ----------------------------------------------------
# 🛡️ AP isolation for HAL-Guest
# ----------------------------------------------------
if ifconfig "${guestSSIDs}" >/dev/null 2>&1; then
  nvram set ${guestSSIDs}_ap_isolate=1
  wl -i ${guestSSIDs} ap_isolate 1
fi

# ----------------------------------------------------
# 📡 Declare wireless interfaces
# ----------------------------------------------------
nvram set wl_ifnames="wl0 wl1 wl2 wl0.1"
nvram commit

# ----------------------------------------------------
# 🔄 Restart wireless daemon
# ----------------------------------------------------
killall eapd 2>/dev/null || true
eapd
