*** Settings ***
Documentation       Configurations for bundle BVI interfaces on DUT1
Library             SSHLibrary
Library             Process
Library             String
Library             Collections
Library             OperatingSystem
Variables           ../../../data/ipv4_arp.yaml
Resource            ../../../resource/common.resource
Resource            ../../../testcases/ipv4robot/ip_route.resource

*** Test Cases ***
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
     Write   interface subif ${bvi.name}; ipv6 address ${bvi.ipv6} prefix ${bvi.prefix6} ; admin-status up
     Commit Testcase
    END

Dad time in Dut1
    [Documentation]    Set Dad time 
    Switch Connection    ${DUT1.hostname}
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
        Write    interface subif ${bvi.name}
        Write  ipv6 nd dad time ${DUT1.dad_time}
    END
    Commit Testcase

Dad Time in DUT2
    [Documentation]   Dad Time 
    Switch Connection    ${DUT2.hostname}
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
        ${output}=   Execute Command  cat /proc/sys/net/ipv6/neigh/${bvi.name}/retrans_time_ms
        ${log_msg}=  Set Variable  dad time are: ${output}
        Log   ${log_msg}
        Should Contain  ${log_msg}   dad time are: ${DUT1.dad_time}
   Exit For Loop
    END
