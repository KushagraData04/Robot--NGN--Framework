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

Configure DUT1 Bundles 
  [Documentation]  Bundles Creation
  Switch Connection    ${DUT1.hostname}
#   Read Until Prompt
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
     Commit Testcase
  END

BVI over Bundle Interface Configuration DUT1
  [Documentation]  BVI over PHY Interfaces Configuration
  Switch Connection    ${DUT1.hostname}
    Write   top;
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     Write   bridge default; allowed-vlan add ${bvi.allowed_vlan}; vlan ${bvi.allowed_vlan}; irb enable 
     Write   bridge default interface ${bvi.port} mode trunk ; trunk allowed vlan add ${bvi.allowed_vlan} 
     Commit Testcase
     Write     top;
     Write   interface subif ${bvi.name}; ipv4 address ${bvi.ip} prefix ${bvi.prefix} ; admin-status up
     Commit Testcase
    END

Proxy Flag in DUT1
    [Documentation]  Set Proxy Flag 
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     ${cli}=  Write   interface subif ${bvi.name} ; 
   Write  arp proxy enable
   ${result}=  Set Variable  ${DUT1.p_flag}
   Log    Result: ${result}
   Commit Testcase
     END
  
Proxy Flag in DUT2
   [Documentation]  Proxy Flag 
   Switch Connection    ${DUT2.hostname}
   FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
   ${output}=  Execute Command  cat /proc/sys/net/ipv4/conf/${bvi.name}/proxy_arp
   Log   Proxy Flag is: ${output}
   END

Compare the Reach Time
   [Documentation]  Comparing Base Reach Time of DUT1 and DUT2
    Log  result is ${result}
    Log  output is ${output}
        Run Keyword If    '${result}' == '${output}'    
    ...    Log    Both values are equal: ${result} == ${output}
    ...  ELSE
    ...    Fail    Comparison failed: ${result} != ${output}