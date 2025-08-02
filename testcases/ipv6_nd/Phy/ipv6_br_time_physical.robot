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

Configure IP Address on DUT1 Interfaces
   [Documentation]    Set IP address for physical interface
   Write     top;
   Read Until Prompt
   FOR    ${phy}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write   interface physical ${phy.number} ; ipv6 address ${phy.ipv6} prefix ${phy.prefix6}
    Commit Testcase 
   END
   Write     top;

Base Reachable Time in Dut1
    [Documentation]  Set base reachable time
    FOR    ${phy}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write   interface physical ${phy.number} ; 
      Write  ipv6 nd reachable-time ${DUT1.br_time}
    Commit Testcase
     END

     Write     top;

Base Reach Time in DUT2
   [Documentation]  Base Reach Time
   Switch Connection    ${DUT2.hostname}
    FOR    ${phy}    IN    @{DUT1.phy_interfaces}
   ${output}=   Execute Command  cat /proc/sys/net/ipv6/neigh/${DUT1.l_name}/base_reachable_time_ms
   Log   Base reachable time is: ${output}
    END