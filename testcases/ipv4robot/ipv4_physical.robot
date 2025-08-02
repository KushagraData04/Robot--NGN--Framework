*** Settings ***
Documentation       Configurations for lxc
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Library             OperatingSystem
# Variables           ../../data/ipv4.yaml
Variables           ../../data/ipv4_route.yaml
Resource            ../../resource/common.resource
Resource            ../../testcases/ipv4robot/ip_route.resource


*** Test Cases ***
###############
#physical setup
###############

Initial Server Configuration
   [Documentation]  Configure to  ${Server158.hostname}
   Switch Connection    ${Server158.hostname}
   # Create network namespaces
   Write  sudo ip netns add ns-pega-228
   Sleep  2s
   Write  ngn@8737
   Write  sudo ip netns add ns-pega-229
   # Move interfaces to respective namespaces
   Write  sudo ip link set eno12399np0 netns ns-pega-228
   Read Until     ngn@ngnngn58:~$
   Write  sudo ip link set eno12409np1 netns ns-pega-229
   Read Until     ngn@ngnngn58:~$

   # Enable loopback interfaces in namespaces
   Write  sudo ip netns exec ns-pega-228 ip link set lo up
   Read Until Prompt

   Write  sudo ip netns exec ns-pega-229 ip link set lo up
   Read Until Prompt

   # Assign IP addresses to interfaces inside namespaces
   Write  sudo ip netns exec ns-pega-228 ip addr add 10.10.10.158/24 dev eno12399np0
   Read Until Prompt
   # Assign IPv6 addresses to interfaces
   Write  sudo ip netns exec ns-pega-228 ip -6 addr add 228:10::158/64 dev eno12399np0
   Read Until Prompt

   Write  sudo ip netns exec ns-pega-228 ip link set eno12399np0 up
   Read Until Prompt

   Write  sudo ip netns exec ns-pega-229 ip addr add 20.20.20.158/24 dev eno12409np1
   Read Until Prompt
   # Assign IPv6 addresses to interfaces
   Write  sudo ip netns exec ns-pega-229 ip -6 addr add 229:20::158/64 dev eno12409np1
   Read Until Prompt

   Write  sudo ip netns exec ns-pega-229 ip link set eno12409np1 up
   Read Until Prompt

Test Route Configuration on Server158
    Configure Routes on Server158

Initial Port Configuration DUT1
   [Documentation]  Configuration ${DUT1.hostname}
   Switch Connection    ${DUT1.hostname}
   # Loop through each port and allocate them
   FOR    ${port}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write    interface physical ${port.number}; link-speed ${port.linkspeed}; admin-status up; 
   END
   Commit Testcase

Configure IP Address on DUT1 Interfaces
   [Documentation]    Set IP address for physical interface
   Write     top;
   Read Until Prompt
   FOR    ${phy}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write  interface physical ${phy.number} ; ipv4 address ${phy.ip} prefix ${phy.prefix}
   END

   FOR    ${phy}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write  interface physical ${phy.number} ; ipv6 address ${phy.ipv6} prefix ${phy.prefix6}
   END
   Commit Testcase
   Write     top;

Test Route Configuration on DUT1
   Configure Route on DUT1

Initial Port Configuration DUT2
   [Documentation]  Configuration ${DUT2.hostname}
   Switch Connection    ${DUT2.hostname}
   # Loop through each port and allocate them
   FOR    ${port}    IN    @{DUT2.phy_interfaces}
   ${cli}=  Write    interface physical ${port.number}; link-speed ${port.linkspeed}; admin-status up; 
   END
   Commit Testcase

Configure IP Address on DUT2 Interfaces
   [Documentation]    Set IP address for physical interface
   Write     top;
   Read Until Prompt
   FOR    ${phy}    IN    @{DUT2.phy_interfaces}
    ${cli}=  Write  interface physical ${phy.number} ; ipv4 address ${phy.ip} prefix ${phy.prefix}
   END

   FOR    ${phy}    IN    @{DUT2.phy_interfaces}
    ${cli}=  Write  interface physical ${phy.number} ; ipv6 address ${phy.ipv6} prefix ${phy.prefix6}
   END
   Commit Testcase
   Write     top;

Test Route Configuration on DUT2
   Configure Route on DUT2

Ping Test
   Switch Connection  ${Server158.hostname}
   Read Until Prompt
   Write    sudo ip netns exec ns-pega-228 ping 20.20.20.158 -c 10 > ping.txt
   Sleep    1s
   Write    ngn@8737
   Sleep    10s
   Read Until Prompt

   Write    sudo ip netns exec ns-pega-228 ping6 229:20::158 -c 5 > ping6.txt
   Sleep    1s
   Write    ngn@8737
   Sleep    15s
   Read Until Prompt

   Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
   Login    ngn    ngn@8737
   Write    cat ping.txt
   ${cli}   Read Until Prompt
   Should Contain    ${cli}     0% packet loss

   Write    cat ping6.txt
   ${cli}   Read Until Prompt
   Should Contain    ${cli}     0% packet loss
   Close Connection

   # Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
   # Login    ngn    ngn@8737

