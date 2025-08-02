import argparse
import random
from scapy.all import Ether, IP, ICMP, sendp, Dot1Q

def random_mac():
    """Generate a random MAC address."""
    return "02:00:00:%02x:%02x:%02x" % (
        random.randint(0, 255),
        random.randint(0, 255),
        random.randint(0, 255)
    )

def send_packet(n, iface, vlan_id):
    destination_ip = "192.168.1.1"

    for i in range(n):
        mac_address = random_mac()
        packet = Ether(src=mac_address) / Dot1Q(vlan=vlan_id) / IP(dst=destination_ip) / ICMP()
        print(f"Sending packet {i+1} with MAC {mac_address} on interface {iface} with VLAN {vlan_id}")
        sendp(packet, verbose=False, iface=iface)
    
    return 'sent'

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Send packets with random MAC addresses and VLAN tagging.')
    parser.add_argument('n', type=int, help='Number of packets to send')
    parser.add_argument('iface', type=str, help='Network interface to use')
    parser.add_argument('vlan_id', type=int, help='VLAN ID to use for tagging')

    args = parser.parse_args()

    print(send_packet(args.n, args.iface, args.vlan_id))

