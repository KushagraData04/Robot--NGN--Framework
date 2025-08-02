from scapy.all import *
import random
#generate random mac by adding random values in last 3 octets
def random_mac():
    """Generate a random MAC address."""
    return "02:00:00:%02x:%02x:%02x" % (
        random.randint(0, 255),
        random.randint(0, 255),
        random.randint(0, 255)
    )

def send_packet(n):
    destination_ip = "192.168.1.1"
    iface = "ens7f1np1"  #interface at which packet is to be sent

    for _ in range(10): #number of packets to be sent
        mac_address = random_mac() #generate a random mac used as smac in packet
        packet = Ether(src=mac_address) / IP(dst=destination_ip) / ICMP() #create packet using inbuilt scapy
        sendp(packet, verbose=False, iface=iface)  #send packet
    
    return 'sent'   #return after successfully transmitting packet

if __name__ == "__main__":
    n = 10  # Specify the number of packets to send
    print(send_packet(n))

