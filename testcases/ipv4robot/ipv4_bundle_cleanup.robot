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
###############
#bundle cleanup
###############

Server Interface Deletion 
  [Documentation]  Configure to  ${Server158.hostname}
  Switch Connection    ${Server158.hostname}
  # Create VLAN Interfaces and Assign IP addresses to interfaces inside namespaces
  Write  sudo ip netns exec ns-pega-228 ip link delete eno12399np0
  Sleep  2s 
  Write  ngn@8737
  Write  sudo ip netns exec ns-pega-229 ip link delete eno12409np1

DUT1 Cleanup
   Switch Connection    ${DUT1.hostname}
   FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=    Write   no interface bundle ${bundle.number}
   END
   Commit Testcase

DUT2 Cleanup
   Switch Connection    ${DUT2.hostname}
   FOR    ${bundle}    IN    @{DUT2.bundle_interfaces}
      ${cli}=    Write   no interface bundle ${bundle.number}
   END
   Commit Testcase

# Ping Test
#   Switch Connection  ${Server158.hostname}
#   # Read Until Prompt
#   Write    sudo ip netns exec ns-pega-228 ping 20.20.20.158 -c 10 > noping3.txt
#   Sleep    1s
#   Write    ngn@8737
#   Sleep    10s
#   Read Until Prompt

#   Write    sudo ip netns exec ns-pega-228 ping6 229:20::158 -c 5 > noping6_3.txt
#   Sleep    1s
#   Write    ngn@8737
#   Sleep    15s
#   Read Until Prompt

#   Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
#   Login    ngn    ngn@8737
#   Write    cat noping3.txt | grep "packet loss"
#   ${cli}    Read Until Prompt
#   Should Contain    ${cli}     100% packet loss

#   Write    cat noping6_3.txt
#   ${cli}   Read Until Prompt
#   Should Contain    ${cli}     100% packet loss
#   Close Connection

# Cleanup IP on the device
#    Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
#    Login    ngn    ngn@8737
#    Switch Connection  ${Server158.hostname}
#    Write  sudo ip netns exec ns-pega-228 ip -6 r del default via 228:10::228
#    Write  sudo ip netns exec ns-pega-229 ip -6 r del default via 229:20::229