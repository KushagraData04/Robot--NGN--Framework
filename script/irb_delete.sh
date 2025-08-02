#!/bin/bash
VLAN=$1
# script to delete all namespaces created
# to run pass paramters like 
#./irb_delete.sh  <vlan-id> 
sudo ip netns delete irb_$VLAN
