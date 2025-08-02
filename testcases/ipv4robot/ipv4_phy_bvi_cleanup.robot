*** Settings ***
Documentation       Configurations for BVI Interfaces IP Testing
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Variables           ../../data/ipv4.yaml
Resource            ../../resource/common.resource


*** Test Cases ***
#####################
#bvi inteface cleanup
#####################

# Server Subif Interface Creation Configuration and IP Assignment
#    [Documentation]  Configure to  ${Server158.hostname}
#    Switch Connection    ${Server158.hostname}
#    # Create VLAN Interfaces and Assign IP addresses to interfaces inside namespaces
#    Write  sudo ip netns exec ns-pega-228 ip link delete eno12399np0.10
#    Sleep  2s 
#    Write  ngn@8737
#    Write  sudo ip netns exec ns-pega-229 ip link delete eno12409np1.20 
  
BVI over PHY Interface Configuration DUT1
  [Documentation]  BVI over PHY Interfaces Configuration
  Switch Connection    ${DUT1.hostname}
    Write   top;
    FOR    ${bvi}    IN    @{DUT1.phy_bvi_interfaces}
      Write   bridge default; vlan ${bvi.allowed_vlan}; irb disable; 
      Commit Testcase
      Write   bridge default 
      Sleep   1s
      Write   no interface ${bvi.port}  
      Commit Testcase
    END

BVI over PHY Interface Configuration DUT2
  [Documentation]  BVI over PHY Interfaces Configuration
  Switch Connection    ${DUT2.hostname}
    Write   top;
    FOR    ${bvi}    IN    @{DUT2.phy_bvi_interfaces}
      Write   bridge default; vlan ${bvi.allowed_vlan}; irb disable; 
      Commit Testcase
      Write   bridge default 
      Sleep   1s
      Write   no interface ${bvi.port}  
      Commit Testcase
    END

# Bridge Removal from Server
#     Switch Connection  ${Server158.hostname}
#     Write  sudo ip netns exec ns-pega-228 ip link delete eno12399np0.10
#     Write  sudo ip netns exec ns-pega-229 ip link delete eno12409np1.20

Ping Test
  Switch Connection  ${Server158.hostname}
  # Read Until Prompt
  Write    sudo ip netns exec ns-pega-228 ping 20.20.20.158 -c 10 > noping2.txt
  Sleep    1s
  Write    ngn@8737
  Sleep    10s
  Read Until Prompt

  Write    sudo ip netns exec ns-pega-228 ping6 229:20::158 -c 10 > noping6_2.txt
  Sleep    1s
  Write    ngn@8737
  Sleep    10s
  Read Until Prompt

  Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
  Login    ngn    ngn@8737
  Write    cat noping2.txt | grep "packet loss"
  ${cli}    Read Until Prompt
  Should Contain    ${cli}     100% packet loss

  Write    cat noping6_2.txt | grep "packet loss"
  ${cli}    Read Until Prompt
  Should Contain    ${cli}     100% packet loss
  Close Connection
  
Bridge Removal from Server
  Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
  Login    ngn    ngn@8737
  Switch Connection  ${Server158.hostname}
  Write  sudo ip netns exec ns-pega-228 ip link delete eno12399np0.10
  Read Until Prompt
  Write  sudo ip netns exec ns-pega-229 ip link delete eno12409np1.20
  Read Until Prompt

  # Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
  # Login    ngn    ngn@8737

# Server Subif Interface Creation Configuration and IP Assignment
#   [Documentation]  Configure to  ${Server158.hostname}
#   Switch Connection    ${Server158.hostname}
#   # Create VLAN Interfaces and Assign IP addresses to interfaces inside namespaces
#   Write  sudo ip netns exec ns-pega-228 ip link delete eno12399np0.10
#   Sleep  2s 
#   Write  ngn@8737
#   Write  sudo ip netns exec ns-pega-229 ip link delete eno12409np1.20
#   Sleep  2s 
#   Write  ngn@8737