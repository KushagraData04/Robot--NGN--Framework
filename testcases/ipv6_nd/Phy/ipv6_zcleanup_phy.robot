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

Remove Base Reachable Time in Dut1
    [Documentation]  Remove base reachable time
    FOR    ${phy}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write   interface physical ${phy.number} ; 
      Write  no interface physical ${phy.number}
    Commit Testcase
     END

     Write     top;