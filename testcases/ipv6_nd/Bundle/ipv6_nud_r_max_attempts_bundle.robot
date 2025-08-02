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
    ${cli}=    Write    ipv6 address ${bundle.ipv6} prefix ${bundle.prefix6}
    Commit Testcase
  END

Nud R Max Attempts in Dut1
    [Documentation]  Set nud r max attempts
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
     Write  ipv6 nd nud-retry max-attempts ${DUT1.nud_r_max_attempts} 
    Commit Testcase
     END

     Write     top;

Nud R Max Attempts in DUT2
   [Documentation]  nud r max attempts 
   Switch Connection    ${DUT2.hostname}
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
   ${output}=   Execute Command  cat /proc/sys/net/ipv6/neigh/bundle-${bundle.number}/ucast_solicit
        ${log_msg}=  Set Variable  unicast is: ${output}
        Log   ${log_msg}
        Should Contain  ${log_msg}   unicast is: ${DUT1.nud_r_max_attempts} 

   ${output}=   Execute Command  cat /proc/sys/net/ipv6/neigh/bundle-${bundle.number}/mcast_solicit
        ${log_msg}=  Set Variable  multicast is: ${output}
        Log   ${log_msg}
        Should Contain  ${log_msg}   multicast is: ${DUT1.nud_r_max_attempts}  
    
   Exit For Loop
    END  