*** Settings ***
Documentation       Configurations for lxc
Library             SSHLibrary
Library             Process
Library             String
Library             Collections
Library             OperatingSystem
Variables           ../../data/ipv4_route.yaml
Resource            ../../resource/common.resource
Resource            ../../testcases/ipv4_route/iproute.resource


*** Test Cases ***
###############
#physical setup
###############

Delete IP Address on DUT1 Interfaces
   [Documentation]    Delete IP address for physical interface
   Switch Connection  ${DUT1.hostname}
   Write   interface physical ${interface_228} ; no ipv4 address ${ip_228} ; exit
   Write   interface physical ${interface_common} ; no ipv4 address ${ip_228_cmn}
   Commit Testcase

Delete IP Address on DUT2 Interfaces
   [Documentation]    Delete IP address for physical interface
   Switch Connection  ${DUT2.hostname}
#    Write   interface physical ${interface_229} ; no ipv4 address ${ip_229} ; exit
#    Write   interface physical ${interface_common} ; no ipv4 address ${ip_229_cmn}
   Write     top;
   Read Until Prompt
   FOR    ${phy}    IN    @{DUT2.phy_interfaces}
     ${cli}=  Write   interface physical ${phy.number} ; no ipv4 address ${phy.ip}
   END
   Commit Testcase