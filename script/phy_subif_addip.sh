#!/bin/bash
IFACE=$5
VLAN=$1
IP_ADDR_START=$2
PREFIX=$3
START=3
END=$(($4 + 2)) 
# script to create devices and assign ip to the subif created at server side
# to run pass paramters like 
#./phy_subif_addip.sh  <vlan-id> <ip-address without prefix(only 3 octets)> <prefix> <number of devices per vlan> <server interface>
for i in $(seq $START $END);
do
	ip a a $IP_ADDR_START.$i/$PREFIX dev $IFACE.$VLAN
done


ip l set dev $IFACE.$VLAN down
ip l set dev $IFACE.$VLAN up
echo "done"
