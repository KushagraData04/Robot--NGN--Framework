import argparse
from scapy.all import Ether, IP, ICMP, sendp

def generate_serial_mac(start_index):
    """Generate a serial MAC address based on the given index."""
    return "02:00:00:%02x:%02x:%02x" % (
        (start_index >> 16) & 0xFF,
        (start_index >> 8) & 0xFF,
        start_index & 0xFF
    )

def send_packet(n, iface, burst):
    destination_ip = "192.168.1.1"
    buffer_size = burst
    packet_buffer = []

    for i in range(n):
        mac_address = generate_serial_mac(i)
        packet = Ether(src=mac_address) / IP(dst=destination_ip) / ICMP()
        packet_buffer.append(packet)

        if (i + 1) % buffer_size == 0 or (i + 1) == n:
            print(f"Sending packets {i+1-buffer_size+1} to {i+1} with serial MACs on interface {iface}")
            sendp(packet_buffer, verbose=False, iface=iface)
            packet_buffer = []

    return 'sent'

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Send packets with serial MAC addresses.')
    parser.add_argument('n', type=int, help='Number of packets to send')
    parser.add_argument('iface', type=str, help='Network interface to use')
    parser.add_argument('burst', type=int, help='size of buffer')
    args = parser.parse_args()

    print(send_packet(args.n, args.iface, args.burst))

