*** Settings ***
Documentation       Configurations for lxc
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Variables           ../../data/ipv4_route.yaml
Resource            ../../resource/common.resource


*** Test Cases ***
##############
#subif cleanup
##############

# Server Subif Interface Deletion 
#    [Documentation]  Configure to  ${Server158.hostname}
#    Switch Connection    ${Server158.hostname}
#    # Create VLAN Interfaces and Assign IP addresses to interfaces inside namespaces
#    Write  sudo ip netns exec ns-pega-228 ip link delete eno12399np0.10
#    Sleep  2s 
#    Write  ngn@8737
#    Write  sudo ip netns exec ns-pega-229 ip link delete eno12409np1.20

Delete Subif Interfaces on DUT1 
   [Documentation]    Set IP address for physical interface
   Switch Connection    ${DUT1.hostname}
   Write     top;
   FOR    ${subif}    IN    @{DUT1.phy_subif_interfaces}
      Write  no interface subif ${subif.name}
   END
   Commit Testcase

Delete Subif Interfaces on DUT2
   [Documentation]    Set IP address for physical interface
   Switch Connection    ${DUT2.hostname}
   Write     top;
   FOR    ${subif}    IN    @{DUT2.phy_subif_interfaces}
      Write  no interface subif ${subif.name}
   END
   Commit Testcase

# Cleanup IP Address on DUT1 Interfaces
#    [Documentation]    Set IP address for physical interface
#    Switch Connection    ${DUT1.hostname}
#    Write     top;
#    FOR    ${phy}    IN    @{DUT1.phy_interfaces}
#      ${cli}=  Write     interface physical ${phy.number} ; no ipv4 address ${phy.ip}
#    END

#    FOR    ${phy}    IN    @{DUT1.phy_interfaces}
#      ${cli}=  Write   interface physical ${phy.number} ; no ipv6 address ${phy.ipv6}
#    END
#    Commit Testcase

# Cleanup IP Address on DUT2 Interfaces
#    [Documentation]    Set IP address for physical interface
#    Switch Connection    ${DUT2.hostname}
#    Write     top;
#    FOR    ${phy}    IN    @{DUT2.phy_interfaces}
#      ${cli}=  Write     interface physical ${phy.number} ; no ipv4 address ${phy.ip}
#    END

#    FOR    ${phy}    IN    @{DUT2.phy_interfaces}
#      ${cli}=  Write   interface physical ${phy.number} ; no ipv6 address ${phy.ipv6}
#    END
#    Commit Testcase

Ping Test
   Switch Connection  ${Server158.hostname}
   # Read Until Prompt
   Write    sudo ip netns exec ns-pega-228 ping 20.20.20.158 -c 10 > noping1.txt
   Sleep    1s
   Write    ngn@8737
   Sleep    15s
   Read Until Prompt

   Write    sudo ip netns exec ns-pega-228 ping6 229:20::158 -c 10 > noping6_1.txt
   Sleep    1s
   Write    ngn@8737
   Sleep    15s
   Read Until Prompt

   Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
   Login    ngn    ngn@8737
   Write    cat noping1.txt
   ${cli}    Read Until Prompt
   Should Contain    ${cli}     100% packet loss
   
   Write    cat noping6_1.txt
   ${cli}    Read Until Prompt
   Should Contain    ${cli}     100% packet loss
   Close Connection

# Server Subif Interface Deletion 
   # [Documentation]  Configure to  ${Server158.hostname}
   # Switch Connection    ${Server158.hostname}
   # # Create VLAN Interfaces and Assign IP addresses to interfaces inside namespaces
   # Write  sudo ip netns exec ns-pega-228 ip link delete eno12399np0.10
   # Sleep  2s 
   # Write  ngn@8737
   # Write  sudo ip netns exec ns-pega-229 ip link delete eno12409np1.20 