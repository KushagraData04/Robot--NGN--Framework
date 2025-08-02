from scapy.all import Ether, IP, UDP, sendp
import random

def generate_random_mac():
    return "02:00:00:%02x:%02x:%02x" % (random.randint(0, 255), random.randint(0, 255), random.randint(0, 255))

def send_mac(num_packets):
    for _ in range(num_packets):
        destination_ip = "192.168.1.1"
        packet = Ether(src=generate_random_mac()) / IP(dst=destination_ip)
        iface = "ens5f0"

       # Send packets continuously at the specified rate on the specified interface
        sendp(packet, verbose=False, iface=iface)
    return 'sent'

if __name__ == "__main__":
    interface = "kr_if_13_eth8"
    num_packets = 1000
    send_packets(interface, num_packets)
    print(f"Sent {num_packets} packets with random source MAC addresses on interface {interface}.")

