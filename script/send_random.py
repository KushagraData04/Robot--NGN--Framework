import argparse
import random
from scapy.all import Ether, IP, ICMP, sendp

def random_mac():
    """Generate a random MAC address."""
    return "02:%02x:%02x:%02x:%02x:%02x" % (
        random.randint(0, 255),
        random.randint(0, 255),
        random.randint(0, 255),
        random.randint(0, 255),
        random.randint(0, 255)
    )

def send_packet(n, iface,burst):
    destination_ip = "192.168.1.1"
    buffer_size = burst
    packet_buffer = []

    for i in range(n):
        mac_address = random_mac()
        packet = Ether(src=mac_address) / IP(dst=destination_ip) / ICMP()
        packet_buffer.append(packet)
        if (i + 1) % 1000 == 0:
            print(f"Buffered packet {i+1} with MAC {mac_address}")

        if len(packet_buffer) >= buffer_size:
            sendp(packet_buffer, verbose=False, iface=iface)
            packet_buffer = []

    # Send any remaining packets in the buffer
    if packet_buffer:
        print(f"Sending the remaining {len(packet_buffer)} packets on interface {iface}")
        sendp(packet_buffer, verbose=False, iface=iface)

    return 'sent'

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Send packets with random MAC addresses.')
    parser.add_argument('n', type=int, help='Number of packets to send')
    parser.add_argument('iface', type=str, help='Network interface to use')

    parser.add_argument('burst', type=int, help='burst size')
    args = parser.parse_args()

    print(send_packet(args.n, args.iface, args.burst))

