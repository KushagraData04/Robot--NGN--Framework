from scapy.all import *
import random
import os
def send_packet(n):
    destination_ip = "192.168.1.1"
    packet = Ether(src="00:11:22:33:44:55") / IP(dst=destination_ip) / ICMP()
    iface = "ens5f0"

# Send packets continuously at the specified rate on the specified interface
    sendp(packet, verbose=False, iface=iface)
    return 'sent'

def send_dmacpacket(n):
    # Define the packet you want to send (e.g., ICMP Ping) with VLAN tag 100
    destination_ip = "192.168.1.1"
    vlan_id = 100
    packet = Ether(dst="00:11:22:33:44:55") / Dot1Q(vlan=vlan_id) / IP(dst=destination_ip) / ICMP()

    # Specify the network interface to send packets on (e.g., ens5f0)
    iface = "ens5f2"

    # Send packets
    sendp(packet*n, verbose=False, iface=iface)
    return 0

if __name__ == "__main__":
    send_packet(1)

