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


Nud R Max Attempts in Dut1
    [Documentation]  Set Nud R Max Attempts
    Switch Connection    ${DUT1.hostname}
    FOR    ${subif}    IN    @{DUT1.bundle_subif_interfaces}
        Write    interface subif ${subif.name}
        Write  ipv6 nd nud-retry max-attempts ${DUT1.nud_r_max_attempts} 
    END
    Commit Testcase

    #  Write     top;

Nud R Max Attempts in DUT2
   [Documentation]  Nud R Max Attempts 
   Switch Connection    ${DUT2.hostname}
    FOR    ${subif}    IN    @{DUT1.bundle_subif_interfaces}
   ${output}=   Execute Command  cat /proc/sys/net/ipv6/neigh/${subif.name}/ucast_solicit
        ${log_msg}=  Set Variable  unicast is: ${output}
        Log   ${log_msg}
        Should Contain  ${log_msg}   unicast is: ${DUT1.nud_r_max_attempts} 

   ${output}=   Execute Command  cat /proc/sys/net/ipv6/neigh/${subif.name}/mcast_solicit
        ${log_msg}=  Set Variable  multicast is: ${output}
        Log   ${log_msg}
        Should Contain  ${log_msg}   multicast is: ${DUT1.nud_r_max_attempts} 
   Exit For Loop
    END

