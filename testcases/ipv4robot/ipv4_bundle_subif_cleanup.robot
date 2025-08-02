*** Settings ***
Documentation       Configurations for lxc
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Variables           ../../data/ipv4.yaml
Resource            ../../resource/common.resource


*** Test Cases ***
###################
#bundle subif setup
###################

# Server Subif Interface Deletion 
#    [Documentation]  Configure to  ${Server158.hostname}
#    Switch Connection    ${Server158.hostname}
#    # Create VLAN Interfaces and Assign IP addresses to interfaces inside namespaces
#    Write  sudo su
#    Sleep  2s
#    Write  ngn@8737
#    Write  ip netns exec ns-pega-228 ip link delete eno12399np0.10 
#    Write  ip netns exec ns-pega-229 ip link delete eno12409np1.20 

Delete Bundle Subif Interfaces on DUT1 
   [Documentation]    Set IP address for physical interface
   Switch Connection    ${DUT1.hostname}
   Write     top;
   FOR    ${subif}    IN    @{DUT1.bundle_subif_interfaces}
     ${cli}=   Write  no interface subif ${subif.name}
   END
   Commit Testcase
   
   FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=   Write  no interface bundle ${bundle.number}
   END
   Commit Testcase

Delete Bundle Subif Interfaces on DUT2
   [Documentation]    Set IP address for physical interface
   Switch Connection    ${DUT2.hostname}
   Write     top;
   FOR    ${subif}    IN    @{DUT2.bundle_subif_interfaces}
     ${cli}=  Write  no interface subif ${subif.name}
   END
   Commit Testcase

   FOR    ${bundle}   IN    @{DUT2.bundle_interfaces}
     ${cli}=   Write  no interface bundle ${bundle.number}
   END
   Commit Testcase

Ping Test
   Switch Connection  ${Server158.hostname}
   # Read Until Prompt
   Write    sudo ip netns exec ns-pega-228 ping 20.20.20.158 -c 5 > noping4.txt
   Sleep    1s
   Write    ngn@8737
   Sleep    15s
   # Read Until Prompt

   Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
   Login    ngn    ngn@8737
   Write    cat noping4.txt
   ${cli}    Read Until Prompt
   Should Contain    ${cli}     100% packet loss
   Close Connection

Server Subif Interface Deletion 
   [Documentation]  Configure to  ${Server158.hostname}
   Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
   Login    ngn    ngn@8737
   Switch Connection    ${Server158.hostname}
   # Create VLAN Interfaces and Assign IP addresses to interfaces inside namespaces
   Write  sudo su
   Sleep  2s
   Write  ngn@8737
   Write  ip netns exec ns-pega-228 ip link delete eno12399np0.10 
   Write  ip netns exec ns-pega-229 ip link delete eno12409np1.20 