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

if __name__ == "__main__":
    send_packet(1)

