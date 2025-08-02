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
    ${cli}=  Write  interface physical ${port.number}; link-speed ${port.linkspeed}; admin-status up; 
   END
   Commit Testcase

Configure IP Address on DUT1 Interfaces
   [Documentation]  Set IP Address on Physical Interface
   Write   top;
   Read Until Prompt
   FOR    ${phy}    IN    @{DUT1.phy_interfaces}
    ${cli}=  Write  interface physical ${phy.number} ; ipv4 address ${phy.ip} prefix ${phy.prefix}
   END
   Commit Testcase
   Write   top;

Retransmit Time in DUT1
   [Documentation]  Retransmit Time
   FOR    ${phy}    IN    @{DUT1.phy_interfaces}
    ${cli}=  Write  interface physical ${phy.number}
   END
   Write  arp retransmit count ${DUT1.rt_count}
   Set Global Variable      ${result}  ${DUT1.rt_count}
   Log    Result: ${result}
   Commit Testcase
  
Retransmit Time in DUT2 
   [Documentation]  Retransmit Time
   Switch Connection    ${DUT2.hostname}
   
   ${cmd_output}=  Execute Command  cat /proc/sys/net/ipv4/neigh/${DUT1.l_name}/ucast_solicit
   Log   Base reachable time is: ${cmd_output}
   Set Global Variable     ${output}  ${cmd_output}

Compare the Retransmit Time
   [Documentation]  Comparing Retransmit Time of DUT1 and DUT2
#    Should Be Equal   ${result}    ${output}
#    Log   Both values are equal: ${result} == ${output}
    Log  result is ${result}
    Log  output is ${output}
        Run Keyword If    '${result}' == '${output}'    
    ...    Log    Both values are equal: ${result} == ${output}
    ...  ELSE
    ...    Fail    Comparison failed: ${result} != ${output}