#### Info #########################################################
#                          RP-AC55 (Merlin)
#
# eth0      Physical Ethernet port (used for uplink; trunked with VLAN 20 & 30)
# eth0.20   VLAN subinterface → br20 (for 5GHz Guest WiFi: wl1.1)
# eth0.30   VLAN subinterface → br30 (for 2.4GHz Guest WiFi: wl0.1)
#
# eth1      (Unused or internal, likely reserved or inactive)
# peth0     (Internal Ethernet alias, usually dormant unless used with VPN/PPP)
#
# wl0       WiFi 2.4GHz main (bridged to br0)
# wl1       WiFi 5GHz main (bridged to br0)
#
# wl0.1     WiFi 2.4GHz guest1 (bridged to br30)
# wl1.1     WiFi 5GHz guest1 (bridged to br20)
#
# br0       Primary bridge (eth0 + wl0 + wl1)
# br20      Guest bridge for wl1.1 and eth0.20 (VLAN 20)
# br30      Guest bridge for wl0.1 and eth0.30 (VLAN 30)
###################################################################

# VLAN IDs
vlan_main=20       # HAL-9000 (Main SSIDs)
vlan_iot=30        # HAL-8000 (IoT SSIDs)

# Interfaces
taggedPort="eth0"
mainSSIDs="wl1 wl1.1"
iotSSIDs="wl0 wl0.1"
virtualSSIDs="wl0.1 wl1.1"

# ----------------------------------------------------
# ✅ Safe Setup: Maintain br0 as primary management bridge
# ----------------------------------------------------

# Create VLAN subinterfaces
ip link add link ${taggedPort} name ${taggedPort}.${vlan_main} type vlan id ${vlan_main}
ip link add link ${taggedPort} name ${taggedPort}.${vlan_iot} type vlan id ${vlan_iot}
ip link set ${taggedPort}.${vlan_main} up
ip link set ${taggedPort}.${vlan_iot} up

# Attach all SSIDs to br0 (safe default)
for iface in ${mainSSIDs} ${iotSSIDs}; do
  brctl addif br0 ${iface}
done

# Attach VLAN-tagged Ethernet interfaces to br0 (pass-through tagging)
brctl addif br0 ${taggedPort}.${vlan_main}
brctl addif br0 ${taggedPort}.${vlan_iot}

# Set LAN bridge NVRAM for GUI and system services
nvram set lan_ifnames="${taggedPort}.${vlan_main} ${taggedPort}.${vlan_iot} ${mainSSIDs} ${iotSSIDs}"
nvram set br0_ifnames="${taggedPort}.${vlan_main} ${taggedPort}.${vlan_iot} ${mainSSIDs} ${iotSSIDs}"
nvram set lan_ifname="br0"
nvram set br0_ifname="br0"

# ----------------------------------------------------
# 🕵️ Enable AP isolation on guest SSIDs (virtuals only)
# ----------------------------------------------------
for iface in ${virtualSSIDs}; do
  if ifconfig "$iface" >/dev/null 2>&1; then
    nvram set ${iface}_ap_isolate=1
    wl -i ${iface} ap_isolate 1
  fi
done

# ----------------------------------------------------
# 📡 Declare wireless interfaces for system tracking
# ----------------------------------------------------
nvram set wl_ifnames="wl0 wl1 wl0.1 wl1.1"
nvram commit

# ----------------------------------------------------
# 🔄 Restart wireless daemon to apply changes
# ----------------------------------------------------
killall eapd 2>/dev/null || true
eapd
