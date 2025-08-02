#!/bin/bash
IFACE=$2
VLAN=$1
# script to delete all subif created on server interface
# to run pass paramters like 
#./irb_delete.sh  <vlan-id> <server interface>
ip l d dev $IFACE.$VLAN
echo "done"
