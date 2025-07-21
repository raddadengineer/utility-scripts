#!/bin/sh

LOGFILE="/jffs/scripts/vlan-bridge.log"
log() {
    echo "$(date): $1" | tee -a "$LOGFILE"
}

log "Starting VLAN bridge setup"

# Remove known interfaces from br0
for iface in wl0.1 wl0.2 wl1.1; do
    if brctl show br0 | grep -q "$iface"; then
        log "Removing $iface from br0"
        brctl delif br0 "$iface"
    else
        log "$iface not on br0, skipping"
    fi
done

# Create VLANs
for vlanid in 20 30 60; do
    IFNAME="eth0.${vlanid}"
    if ! ip link show "$IFNAME" > /dev/null 2>&1; then
        log "Creating VLAN interface $IFNAME"
        ip link add link eth0 name "$IFNAME" type vlan id "$vlanid"
        ip link set "$IFNAME" up
    else
        log "$IFNAME already exists"
    fi
done

# Create bridges and add interfaces
create_bridge() {
    BR=$1
    ETH=$2
    WIFI=$3

    if ! brctl show | grep -q "^$BR"; then
        log "Creating bridge $BR"
        brctl addbr "$BR"
        ip link set "$BR" up
    else
        log "Bridge $BR already exists"
    fi

    log "Adding $ETH to $BR"
    brctl addif "$BR" "$ETH"

    log "Adding $WIFI to $BR"
    brctl addif "$BR" "$WIFI"
}

create_bridge br20 eth0.20 wl0.1
create_bridge br30 eth0.30 wl1.1
create_bridge br60 eth0.60 wl0.2

log "VLAN bridge setup complete"

