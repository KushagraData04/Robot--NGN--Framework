*** Settings ***
Documentation       Configurations for BVI Interfaces IP Testing
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Variables           ../../data/ipv4_route.yaml
Resource            ../../resource/common.resource
Resource            ../../testcases/ipv4robot/ip_route.resource


*** Test Cases ***
###############################
#bvi over bundle inteface setup 
###############################

Server Subif Interface Creation Configuration and IP Assignment
  [Documentation]  Configure to  ${Server158.hostname}
  Switch Connection    ${Server158.hostname}
  # Create VLAN Interfaces and Assign IP addresses to interfaces inside namespaces
  Write  sudo su
  Sleep  2s
  Write  ngn@8737
  Write  ip netns exec ns-pega-228 ip link add link eno12399np0 name eno12399np0.10 type vlan id 10
  Write  ip netns exec ns-pega-228 ip link set eno12399np0.10 up
  Write  ip netns exec ns-pega-228 ip addr add 10.10.10.158/24 dev eno12399np0.10
  Write  sudo ip netns exec ns-pega-228 ip addr add 228:10::158/64 dev eno12399np0.10

  Write  ip netns exec ns-pega-229 ip link add link eno12409np1 name eno12409np1.20 type vlan id 20
  Write  ip netns exec ns-pega-229 ip link set eno12409np1.20 up
  Write  ip netns exec ns-pega-229 ip addr add 20.20.20.158/24 dev eno12409np1.20
  Write  sudo ip netns exec ns-pega-229 ip addr add 229:20::158/64 dev eno12409np1.20

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
     Commit Testcase
  END

BVI over Bundle Interface Configuration DUT1
  [Documentation]  BVI over PHY Interfaces Configuration
  Switch Connection    ${DUT1.hostname}
    Write   top;
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     Write   bridge default; allowed-vlan add ${bvi.allowed_vlan}; vlan ${bvi.allowed_vlan}; irb enable 
     Write   bridge default interface ${bvi.port} mode trunk ; trunk allowed vlan add ${bvi.allowed_vlan} 
     Commit Testcase
     Write     top;
     Write   interface subif ${bvi.name}; ipv4 address ${bvi.ip} prefix ${bvi.prefix} ; admin-status up
     Write   interface subif ${bvi.name}; ipv6 address ${bvi.ipv6} prefix ${bvi.prefix6} ; admin-status up
     Commit Testcase
    END

Test Route Configuration on DUT1
  Configure Route on DUT1

Configure DUT2 Bundles 
  [Documentation]  Bundles Creation
  Switch Connection    ${DUT2.hostname}
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
     Commit Testcase
  END

BVI over Bundle Interface Configuration DUT2
  [Documentation]  BVI over PHY Interfaces Configuration
  Switch Connection    ${DUT2.hostname}
    Write   top;
    FOR    ${bvi}    IN    @{DUT2.bundle_bvi_interfaces}
     Write   bridge default; allowed-vlan add ${bvi.allowed_vlan}; vlan ${bvi.allowed_vlan}; irb enable 
     Write   bridge default interface ${bvi.port} mode trunk ; trunk allowed vlan add ${bvi.allowed_vlan} 
     Commit Testcase
     Write     top;
     Write   interface subif ${bvi.name}; ipv4 address ${bvi.ip} prefix ${bvi.prefix} ; admin-status up
     Write   interface subif ${bvi.name}; ipv6 address ${bvi.ipv6} prefix ${bvi.prefix6} ; admin-status up
     Commit Testcase
    END

Test Route Configuration on DUT2
  Configure Route on DUT2

Ping Test
  Switch Connection  ${Server158.hostname}
  # Read Until Prompt
  Write    sudo ip netns exec ns-pega-228 ping 20.20.20.158 -c 10 > ping5.txt
  Sleep    1s
  Write    ngn@8737
  Sleep    10s
  # Read Until Prompt
  Write    sudo ip netns exec ns-pega-228 ping6 229:20::158 -c 10 > ping6_5.txt
  Sleep    1s
  Write    ngn@8737
  Sleep    10s
  # Read Until Prompt

  Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
  Login    ngn    ngn@8737
  Write    cat ping5.txt | grep "packet loss"
  ${cli}   Read Until Prompt
  Should Contain    ${cli}     0% packet loss

  Write    cat ping6_5.txt
  ${cli}    Read Until Prompt
  Should Contain    ${cli}     0% packet loss
  Close Connection

  Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
  Login    ngn    ngn@8737