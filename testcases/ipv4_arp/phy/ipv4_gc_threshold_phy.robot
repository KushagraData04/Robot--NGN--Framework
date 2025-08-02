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

GC_Threshold in DUT1
   [Documentation]  GC_Threshold
   FOR    ${phy}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write   interface physical ${phy.number}
   END
   ${result}=  Write   arp gc-threshold ${DUT1.gc_threshold} 
   Log    Division Result: ${result}
   Commit Testcase
  
GC_Threshold in DUT2 
   [Documentation]  GC_Threshold
   Switch Connection    ${DUT2.hostname}
   ${output}=   Execute Command  cat /proc/sys/net/ipv4/neigh/default/gc_thresh1
   Log   Base reachable time is: ${output}

Compare the Reach Time
   [Documentation]  Comparing Base Reach Time of DUT1 and DUT2
   Should Be Equal   ${result}    ${output}
   Log    Both values are equal: ${result} == ${output}