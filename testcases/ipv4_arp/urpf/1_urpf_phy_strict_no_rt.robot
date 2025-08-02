*** Settings ***
Documentation       Configurations for lxc
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Library             OperatingSystem
# Variables           ../../data/ipv4.yaml
Variables           ../../../data/ipv4_route.yaml
Resource            ../../../resource/common.resource
Resource            ../../../testcases/ipv4robot/ip_route.resource


*** Test Cases ***
###############
#physical setup
###############

Initial Server Configuration
   [Documentation]  Configure to  ${Server158.hostname}
  Switch Connection    ${Server158.hostname}

# Create network namespaces
   Write    sudo ip netns add ns-pega-228
   Sleep    2s
   Write    ngn@8737
   Write    sudo ip netns add ns-pega-229

   # Get interface names from ports list
   ${port0}=    Get From List          ${Server158.ports}        0
   ${iface0}=   Get From Dictionary    ${port0}        name

   ${port1}=    Get From List          ${Server158.ports}        1
   ${iface1}=   Get From Dictionary    ${port1}        name

   # Move interfaces to respective namespaces
   Write    sudo ip link set ${iface0} netns ns-pega-228
   Read Until    ngn@ngnngn58:~$

   Write    sudo ip link set ${iface1} netns ns-pega-229
   Read Until    ngn@ngnngn58:~$

   # Enable loopback interfaces in namespaces
   Write    sudo ip netns exec ns-pega-228 ip link set lo up
   Read Until Prompt

   Write    sudo ip netns exec ns-pega-229 ip link set lo up
   Read Until Prompt

   # Assign IP addresses to interfaces inside namespaces
   Write    sudo ip netns exec ns-pega-228 ip addr add 10.10.10.158/24 dev ${iface0}
   Read Until Prompt

   # Write    sudo ip netns exec ns-pega-228 ip -6 addr add 228:10::158/64 dev ${iface0}
   # Read Until Prompt

   Write    sudo ip netns exec ns-pega-228 ip link set ${iface0} up
   Read Until Prompt

   Write    sudo ip netns exec ns-pega-229 ip addr add 20.20.20.158/24 dev ${iface1}
   Read Until Prompt

   # Write    sudo ip netns exec ns-pega-229 ip -6 addr add 229:20::158/64 dev ${iface1}
   # Read Until Prompt

   Write    sudo ip netns exec ns-pega-229 ip link set ${iface1} up
   Read Until Prompt


Test Route Configuration on Server158
    Configure Routes on Server158

Initial Port Configuration DUT1
   [Documentation]  Configuration ${DUT1.hostname}
   Switch Connection    ${DUT1.hostname}
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
    ${cli}=  Write  interface physical ${phy.number} ; ipv4 rpf strict ; ipv4 address ${phy.ip} prefix ${phy.prefix}
   END
   Commit Testcase
   Write     top;

Ping Test
   Open Connection    ${Server}    alias=${Server158.hostname}    prompt=${DUT_PROMPT3}    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
   Login    ngn    ngn@8737
   Switch Connection    ${Server158.hostname}

   Write  sudo timeout ${3*${Pcounter}} sudo ip netns exec ns-pega-229 tcpdump -i eno12409np1 -nle src 40.40.40.228 and dst 20.20.20.158 > /tmp/urpf240.txt 2>&1
   Sleep  2s
   Write  ngn@8737


   Open Connection    ${DUT_IP1}    alias=${DUT1.hostname}    prompt=${DUT_PROMPT}      timeout=${DUT_TIMEOUT}     port=${DUT1.ssh_port}
   Login    ${DUT_USERNAME1}    ${DUT_PASSWORD1}
   Switch Connection  ${DUT1.hostname}
   Write    ping -I 40.40.40.228 20.20.20.158 -c ${Pcounter}
   Sleep    ${3*${Pcounter}}s
    
   # Open Connection    ${Server}    alias=${Server158.hostname}    prompt=${DUT_PROMPT3}    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
   # Login    ngn    ngn@8737
   Switch Connection    ${Server158.hostname}
   Read Until Prompt
   Sleep  10s
   # Read the captured output file
   Write    ngn@8737
   Read Until Prompt
   Write    cat /tmp/urpf240.txt 
   ${output}=  Read Until Prompt
   Log    ${output}
   Should Contain    ${output}   0 packets captured  


   # Check if file is empty (strict RPF) or contains packet exchange (loose/disabled)
   Run Keyword If  '0 packets captured' in """${output}""" and 'listening on eno12409np1' in """${output}"""
   ...    Log    RPF mode is STRICT

   Run Keyword If    'ICMP echo request' in """${output}""" and 'ICMP echo reply' in """${output}"""
   ...    Log    RPF mode is LOOSE or DISABLED    

   Run Keyword If    'LLDP' in """${output}"""    
   ...    Log    LLDP Packet Detected - Likely No ICMP Response Captured

   

