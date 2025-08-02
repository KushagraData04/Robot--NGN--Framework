from scapy.all import *
def send_packet100(num_packets):
    # Define the packet you want to send (e.g., ICMP Ping) with VLAN tag 100
    destination_ip = "192.168.1.1"
    vlan_id = 100
    packet = Ether(src="00:11:22:33:44:55") / Dot1Q(vlan=vlan_id) / IP(dst=destination_ip) / ICMP()

    # Specify the network interface to send packets on (e.g., ens5f0)
    iface = "ens5f0"

    # Send packets
    sendp(packet*num_packets, verbose=False, iface=iface)
    return 0

def send_packet101(num_packets):
    # Define the packet you want to send (e.g., ICMP Ping) with VLAN tag 100
    destination_ip = "192.168.1.1"
    vlan_id = 101
    packet = Ether(src="00:11:22:33:44:55") / Dot1Q(vlan=vlan_id) / IP(dst=destination_ip) / ICMP()

    # Specify the network interface to send packets on (e.g., ens5f0)
    iface = "ens5f0"

    # Send packets
    sendp(packet*num_packets, verbose=False, iface=iface)
    return 0


def send_packet201(num_packets):
    # Define the packet you want to send (e.g., ICMP Ping) with VLAN tag 100
    destination_ip = "192.168.1.1"
    vlan_id = 201
    packet = Ether(src="00:11:22:33:44:55") / Dot1Q(vlan=vlan_id) / IP(dst=destination_ip) / ICMP()

    # Specify the network interface to send packets on (e.g., ens5f0)
    iface = "ens5f0"

    # Send packets
    sendp(packet*num_packets, verbose=False, iface=iface)
    return 0
def send_packet1(num_packets):
    # Define the packet you want to send (e.g., ICMP Ping) with VLAN tag 100
    destination_ip = "192.168.1.1"
    vlan_id = 1
    packet = Ether(src="00:11:22:33:44:55") / Dot1Q(vlan=vlan_id) / IP(dst=destination_ip) / ICMP()

    # Specify the network interface to send packets on (e.g., ens5f0)
    iface = "ens5f0"

    # Send packets
    sendp(packet*num_packets, verbose=False, iface=iface)
    return 0

if __name__ == "__main__":
    num_packets_to_send = 10000
    send_packet200(num_packets_to_send)

