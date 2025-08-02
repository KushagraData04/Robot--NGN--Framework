#!/bin/bash
VLAN=$1
IP_ADDR=$2
GATEWAY=$3
IFACE=$4
# script to create multiple subif at server side instead namespaces 
# to run pass paramters like 
#./irb_create.sh  <vlan-id> <ip-address without prefix> <gateway ip-address> <server interface>
sudo ip l a link $IFACE name $IFACE.$VLAN type vlan id $VLAN
sudo ip netns add irb_$VLAN
sudo ip link set dev $IFACE.$VLAN netns irb_$VLAN
sudo ip netns exec irb_$VLAN ip a a $IP_ADDR/24 dev $IFACE.$VLAN
sudo ip netns exec irb_$VLAN ip l set dev $IFACE.$VLAN up
sudo ip netns exec irb_$VLAN ip r a default via $GATEWAY
