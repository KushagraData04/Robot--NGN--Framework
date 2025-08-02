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

Create VRF in DUT1
   [Documentation]    Create VRF
   Switch Connection  ${DUT1.hostname}
   Write     top;
   Read Until Prompt
   ${cli}=  Write  vrf ip_testing228 ; exit
   Commit Testcase

Assigning IP on the DUT1 Interface
   [Documentation]    IP assignment on interface
   Write     top;
   FOR    ${phy}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write   interface physical ${phy.number} ; vrf ip_testing228 ipv4 address ${phy.ip} prefix ${phy.prefix}
   END
   Commit Testcase

Verify the result in DUT1
   Write  do show interface configuration brief vrf ip_testing228
   Read Until  "Interface phy-1_12_1"

Create VRF in DUT2
   [Documentation]    Create VRF
   Switch Connection  ${DUT2.hostname}
   Write     top;
   Read Until Prompt
   ${cli}=  Write  vrf ip_testing229 ; exit
   Commit Testcase

Assigning IP on the DUT2 Interface
   [Documentation]    IP assignment on interface
   Write     top;
   FOR    ${phy}    IN    @{DUT2.phy_interfaces}
     ${cli}=  Write   interface physical ${phy.number} ; vrf ip_testing229 ipv4 address ${phy.ip} prefix ${phy.prefix}
   END
   Commit Testcase

Verify the result in DUT2
   Write  do show interface configuration brief vrf ip_testing229
   Read Until  "Interface phy-1_12_1"