#!/bin/bash
VLAN=$1
IP_ADDR=$2
# script used to ping a particular subif ip from server end and return successful and failed based on output
# to run pass paramters like 
#./irb_ping.sh  <vlan-id> <ip address>
sudo ip netns exec irb_$VLAN ping -c 1 -W 1 $IP_ADDR &> /dev/null
if [ $? -eq 0 ]; then
     echo "Ping successful: $IP_ADDR"
else
     echo "Ping failed: $IP_ADDR"
fi
