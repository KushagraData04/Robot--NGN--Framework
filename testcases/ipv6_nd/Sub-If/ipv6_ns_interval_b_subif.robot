*** Settings ***
Documentation       Configurations for lxc
Library             SSHLibrary
Library             Process
Library             String
Library             Collections
Library             OperatingSystem
Variables           ../../../data/ipv4_arp.yaml
Resource            ../../../resource/common.resource
Resource            ../../../testcases/ipv4robot/ip_route.resource


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
  END
  Commit Testcase

Configure IP Address on DUT1 Bundle Subif Interfaces
  [Documentation]    Set IP address for bundle interface
  Switch Connection    ${DUT1.hostname}
  Write     top;
  FOR    ${subif}    IN    @{DUT1.bundle_subif_interfaces}
   Write     interface subif ${subif.name}; admin-status up; ipv6 address ${subif.ipv6} prefix ${subif.prefix}
   Commit Testcase
  END


NS Interval in Dut1
    [Documentation]  Set NS Interval 
    Switch Connection    ${DUT1.hostname}
    FOR    ${subif}    IN    @{DUT1.bundle_subif_interfaces}
        Write    interface subif ${subif.name}
        Write  ipv6 nd ns-interval ${DUT1.ns_interval} 
    END
    Commit Testcase

    #  Write     top;

NS Interval in DUT2
   [Documentation]  Dad Time
   Switch Connection    ${DUT2.hostname}
    FOR    ${subif}    IN    @{DUT1.bundle_subif_interfaces}
   ${output}=   Execute Command  cat /proc/sys/net/ipv6/neigh/${subif.name}/retrans_time_ms
        ${log_msg}=  Set Variable  ns interval is: ${output}
        Log   ${log_msg}
        Should Contain  ${log_msg}   ns interval is: ${DUT1.ns_interval} 
   Exit For Loop
    END

