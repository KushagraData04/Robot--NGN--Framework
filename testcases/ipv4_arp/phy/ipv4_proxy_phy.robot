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

Proxy Flag in DUT1
   [Documentation]  Proxy Flag
   FOR    ${phy}    IN    @{DUT1.phy_interfaces}
    ${cli}=  Write  interface physical ${phy.number}
   END
   Write  arp proxy enable
   ${result}=  Set Variable  ${DUT1.p_flag}
   Log    Result: ${result}
   Commit Testcase
  
Proxy Flag in DUT2 
   [Documentation]  Proxy Flag
   Switch Connection    ${DUT2.hostname}
   ${output}=  Execute Command  cat /proc/sys/net/ipv4/conf/${DUT1.l_name}/proxy_arp
   Log   Proxy Flag is: ${output}

Compare the Flags
   [Documentation]  Comparing Flags of DUT1 and DUT2
   Run Keyword If    '${result}' == '${output}'    
   ...    Log    Both values are equal and proxy is enabled: ${result} == ${output}
   ...  ELSE
   ...    Fail    Comparison failed: ${result} != ${output}