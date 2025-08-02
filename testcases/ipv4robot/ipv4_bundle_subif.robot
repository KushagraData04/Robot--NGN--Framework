*** Settings ***
Documentation       Configurations for lxc
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Variables           ../../data/ipv4.yaml
Resource            ../../resource/common.resource
Resource            ../../testcases/ipv4robot/ip_route.resource


*** Test Cases ***
###################
#bundle subif setup
###################

Server Subif Interface Creation Configuration and IP Assignment
  [Documentation]  Configure to  ${Server158.hostname}
  Switch Connection    ${Server158.hostname}
  # Write  sudo ip netns exec ns-pega-228 ip addr del 10.10.10.158/24 dev eno12399np0
  # Sleep  2s
  # Write  ngn@8737
  # Write  sudo ip netns exec ns-pega-229 ip addr del 20.20.20.158/24 dev eno12409np1
  # # Create VLAN Interfaces and Assign IP addresses to interfaces inside namespaces
  # Write  sudo ip netns exec ns-pega-228 ip link add link eno12399np0 name eno12399np0.10 type vlan id 10
  # Write  sudo ip netns exec ns-pega-228 ip link set eno12399np0.10 up
  # Write  sudo ip netns exec ns-pega-228 ip addr add 10.10.10.158/24 dev eno12399np0.10
  # Write  sudo ip netns exec ns-pega-229 ip link add link eno12409np1 name eno12409np1.20 type vlan id 20
  # Write  sudo ip netns exec ns-pega-229 ip link set eno12409np1.20 up
  # Write  sudo ip netns exec ns-pega-229 ip addr add 20.20.20.158/24 dev eno12409np1.20

  Write  sudo ip netns exec ns-pega-228 ip addr del 10.10.10.158/24 dev eno12399np0
  Sleep  2s
  Write  ngn@8737
  Write  sudo ip netns exec ns-pega-228 ip link add link eno12399np0 name eno12399np0.10 type vlan id 10
  Read Until Prompt
  Write  sudo ip netns exec ns-pega-228 ip link set eno12399np0.10 up
  Read Until Prompt
  Write  sudo ip netns exec ns-pega-228 ip addr add 10.10.10.158/24 dev eno12399np0.10
  Read Until Prompt
  Write  sudo ip netns exec ns-pega-229 ip addr del 20.20.20.158/24 dev eno12409np1
  Read Until Prompt
  Write  sudo ip netns exec ns-pega-229 ip link add link eno12409np1 name eno12409np1.20 type vlan id 20
  Read Until Prompt
  Write  sudo ip netns exec ns-pega-229 ip link set eno12409np1.20 up
  Read Until Prompt
  Write  sudo ip netns exec ns-pega-229 ip addr add 20.20.20.158/24 dev eno12409np1.20
  Sleep  2s

Test Route Configuration on Server158
  Configure Routes on Server158

Configure DUT1 Bundles 
  [Documentation]  Bundles Creation
  Switch Connection    ${DUT1.hostname}
#   Read Until Prompt
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
  END
  Commit Testcase

Configure IP Address on DUT1 Bundle Subif Interfaces
  [Documentation]    Set IP address for physical interface
  Switch Connection    ${DUT1.hostname}
  Write     top;
  FOR    ${subif}    IN    @{DUT1.bundle_subif_interfaces}
   Write     interface subif ${subif.name}; admin-status up; ipv4 address ${subif.ip} prefix ${subif.prefix}
  END
  Commit Testcase

Test Route Configuration on DUT1
  Configure Route on DUT1

Configure DUT2 Bundles 
  [Documentation]  Bundles Creation
  Switch Connection    ${DUT2.hostname}
  Write  top;
  # Loop through each bundle and configure it with ports and mode
  FOR    ${bundle}    IN    @{DUT2.bundle_interfaces}
  ${cli}=    Write    interface bundle ${bundle.number}
    FOR    ${port}    IN    @{bundle.port}
     ${cli}=    Write    port ${port}
    END
    ${cli}=    Write    mode ${bundle.mode}; admin-status up
  
    IF  "${bundle.mode}" != "loadbalance"
     ${cli}=    Write   lacp rate ${bundle.lacp_rate};
    END
  END
  Commit Testcase

Configure IP Address on DUT2 Bundle Subif Interfaces
  [Documentation]    Set IP address for physical interface
  Switch Connection    ${DUT2.hostname}
  Write     top;
  FOR    ${subif}    IN    @{DUT2.bundle_subif_interfaces}
   Write  interface subif ${subif.name} ; admin-status up; ipv4 address ${subif.ip} prefix ${subif.prefix}
  END
  Commit Testcase

Test Route Configuration on DUT2
  Configure Route on DUT2

Ping Test
  Switch Connection  ${Server158.hostname}
  Read Until Prompt
  Write  sudo ip netns exec ns-pega-228 ping 20.20.20.158 -c 10 > ping4.txt
  Sleep    1s
  Write    ngn@8737
  Sleep    10s
  Read Until Prompt
  
  Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
  Login    ngn    ngn@8737
  Write    cat ping4.txt
  ${cli}   Read Until Prompt
  Should Contain    ${cli}     0% packet loss
  Close Connection

  # Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
  # Login    ngn    ngn@8737