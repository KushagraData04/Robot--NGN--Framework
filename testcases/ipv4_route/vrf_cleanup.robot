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
############
#vrf_cleanup
############

Deleting IP on the DUT1 Interface
   [Documentation]  Deleting IP on Interface
   Switch Connection  ${DUT1.hostname}
   FOR  ${phy}  IN  @{DUT1.phy_interfaces}
     ${cli} =  Write  interface physical ${phy.number} ; no vrf
   END
   Commit Testcase

Deleting IP on the DUT2 Interface
   [Documentation]  Deleting IP on Interface
   Switch Connection  ${DUT2.hostname}
   FOR  ${phy}  IN  @{DUT2.phy_interfaces}
     ${cli} =  Write  interface physical ${phy.number} ; no vrf
   END
   Commit Testcase
