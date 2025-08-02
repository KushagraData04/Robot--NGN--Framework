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
   [Documentation]  Configuration ${DUT1.hostname}
   Switch Connection    ${DUT1.hostname}
   # Loop through each port and allocate them
   FOR    ${port}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write   interface physical ${port.number}; link-speed ${port.linkspeed}; admin-status up; 
    Commit Testcase
   END

Configure Bundles and Ip on Bundle DUT1 bundle interfaces
  [Documentation]  Bundles Creation
  Switch Connection    ${DUT1.hostname}
  Enter Config Mode
  Read Until Prompt
  # Loop through each bundle and configure it with ports and mode
  FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
  ${cli}=    Write    interface bundle ${bundle.number}
    FOR    ${port}    IN    @{bundle.port}
    ${cli}=    Write    port ${port}
    END
    ${cli}=    Write    mode ${bundle.mode}; admin-status up
  
    IF  "${bundle.mode}" != "loadbalance"
    ${cli}=    Write   lacp rate ${bundle.lacp_rate};
    END
    ${cli}=    Write    ipv4 address ${bundle.ip} prefix ${bundle.prefix}
    Commit Testcase
  END

Retransmit Time in DUT1
    [Documentation]  Retransmit Time 
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
   Write  arp retransmit count ${DUT1.rt_count}
   Set Global Variable      ${result}  ${DUT1.rt_count}
   Log    Result: ${result}
   Commit Testcase
     END
  
Retransmit Time in DUT2 
   [Documentation]  Retransmit Time 
   Switch Connection    ${DUT2.hostname}
   FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
   ${cmd_output}=  Execute Command  cat /proc/sys/net/ipv4/neigh/bundle-${bundle.number}/ucast_solicit
   Log   Base reachable time is: ${cmd_output}
   Set Global Variable     ${output}  ${cmd_output}
   END

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