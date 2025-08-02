import argparse
import random
from scapy.all import Ether, IP, ICMP, sendp

def random_mac():
    """Generate a random MAC address."""
    return "02:00:00:%02x:%02x:%02x" % (
        random.randint(0, 255),
        random.randint(0, 255),
        random.randint(0, 255)
    )

def send_packet(n, iface, source_ip):
    destination_ip = "192.168.1.1"
    buffer_size = 100
    packet_buffer = []

    for i in range(n):
        mac_address = random_mac()
        packet = Ether(src=mac_address) / IP(src=source_ip, dst=destination_ip) / ICMP()
        #print(f"Sending packet {i+1} with MAC {mac_address} on interface {iface} with source IP {source_ip}")
        packet_buffer.append(packet)
        if (i + 1) % buffer_size == 0 or (i + 1) == n:
            print(f"Sending packets {i+1-buffer_size+1} to {i+1} with serial MACs on interface {iface}")
            sendp(packet_buffer, verbose=False, iface=iface)
            packet_buffer = []
    
    return 'sent'

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Send packets with random MAC addresses and source IP.')
    parser.add_argument('n', type=int, help='Number of packets to send')
    parser.add_argument('iface', type=str, help='Network interface to use')
    parser.add_argument('source_ip', type=str, help='Source IP address to use for the packets')

    args = parser.parse_args()

    print(send_packet(args.n, args.iface, args.source_ip))

