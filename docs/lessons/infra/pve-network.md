# Lessons: PVE Network

## VMs not communicating despite correct IP
**Symptom:** `Destination Host Unreachable`, tcpdump shows no ARP on interface
**Cause:** VMs were assigned different bridges in PVE GUI (Hardware → Network Device)
**Fix:** Ensure all VMs on the same L2 network use identical bridge in PVE GUI
**Debug path:** tcpdump -i <iface> arp → silence = L2 problem → check PVE bridge config