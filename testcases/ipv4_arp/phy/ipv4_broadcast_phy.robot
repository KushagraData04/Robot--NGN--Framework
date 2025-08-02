*** Settings ***
Documentation       Configurations for lxc
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Library             OperatingSystem
Variables           ../../../data/ipv4_arp.yaml
Resource            ../../../resource/common.resource

*** Variables ***
${result}
${output}

*** Test Cases ***
###############
#physical setup
###############

Initial Port Configuration DUT1
   [Documentation]  Configuration of Port ${DUT1.hostname}
   Switch Connection    ${DUT1.hostname}
   # Loop through each port and allocate them
   FOR    ${port}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write    interface physical ${port.number}; link-speed ${port.linkspeed}; admin-status up; 
   END
   Commit Testcase

Configure IP Address on DUT1 Interfaces
   [Documentation]  Set IP Address on Physical Interface
   Write     top;
   Read Until Prompt
   FOR    ${phy}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write     interface physical ${phy.number} ; ipv4 address ${phy.ip} prefix ${phy.prefix}
   END
   Commit Testcase
   Write     top;

Broadcast Address Time in DUT1
   [Documentation]  Broadcast Address Time
   FOR    ${phy}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write   interface physical ${phy.number}
   ${result}=   Write   ipv4 broadcast ${DUT1.broadcast_addr}
   Log    Division Result: ${result}
   END
   Commit Testcase
  
Broadcast Address Time in DUT2 
   [Documentation]  Broadcast Address Time
   Switch Connection    ${DUT2.hostname}
   ${output}=   Execute Command   ip r show table local | grep ${DUT1.broadcast_addr}
   Log   Base reachable time is: ${output}

# Compare the Reach Time
#    [Documentation]  Comparing Base Reach Time of DUT1 and DUT2
#    Should Be Equal   ${result}    ${output}
#    Log    Both values are equal: ${result} == ${output}