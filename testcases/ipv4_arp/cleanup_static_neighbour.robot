*** Settings ***
Documentation       Configurations for lxc
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Variables           ../../data/ipv4_arp.yaml
Resource            ../../resource/common.resource


*** Test Cases ***
#################
#physical cleanup
#################

IPV4 Deletion 
   [Documentation]  Deleting IPV4 Neighbour
   Switch Connection    ${DUT1.hostname}
   FOR    ${phy}    IN    @{DUT1.phy_interface}
    ${cli}=  Write  interface physical ${phy.number}
   END
   Write  no ipv4 neighbour
   Commit Testcase