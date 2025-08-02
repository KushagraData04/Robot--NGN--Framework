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

Base Reach Time in DUT1
   [Documentation]  Base Reach Time
   FOR    ${phy}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write   interface physical ${phy.number}
   END
   Write   arp base-reachable-time ${DUT1.br_time}
   ${result}=   Evaluate   int(${DUT1.br_time} / 1000)
   Log    Division Result: ${result}
   Commit Testcase
  
Base Reach Time in DUT2 
   [Documentation]  Base Reach Time
   Switch Connection    ${DUT2.hostname}
   ${output}=   Execute Command  cat /proc/sys/net/ipv4/neigh/${DUT1.l_name}/base_reachable_time
   Log   Base reachable time is: ${output}

Compare the Reach Time
   [Documentation]  Comparing Base Reach Time of DUT1 and DUT2
   Should Be Equal   ${result}    ${output}
   Log    Both values are equal: ${result} == ${output}