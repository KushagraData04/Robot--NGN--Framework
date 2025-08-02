#!/bin/bash
IFACE=$4
VLAN=$1
IP_ADDR=$2
GATEWAY=$3
# script to create multiple subif at server
# to run pass paramters like 
#./phy_suif_create.sh  <vlan-id> <ip-address with prefix> <gateway ip-address> <server interface>
ip l a link $IFACE name $IFACE.$VLAN type vlan id $VLAN
ip a a $IP_ADDR dev $IFACE.$VLAN
ip l set dev $IFACE.$VLAN up
ping -c 1 $GATEWAY
echo "sent"
