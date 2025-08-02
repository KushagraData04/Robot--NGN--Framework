*** Settings ***
Documentation       Test case to check flooding
Library             NetmikoLibrary
Library             Process
Library             1.py
Library             OperatingSystem
Default Tags        layer2
Resource            resource/common.resource
Variables           data/dut2.yaml
Suite Setup         Connect to device

*** Test Cases ***

Add server port to bridge
    Enter Config Mode
    [Documentation]     Add 2 server port with 100 vlan and 1 dut interface with 100 vlan in bridge 
    # Configure the bridge with two ports
    ${cli}=             Cli    config
    ${cli}=             Cli    bridge default;allowed-vlan add 100,200 ; vlan 100; vlan 200;
    Commit Testcase
    ${cli}=             Cli    exit;interface ${dut_iface2};mode access; access vlan 100;
    ${cli}=             Cli    exit;interface ${serverport2};mode access; access vlan 100;
    ${cli}=             Cli    exit;interface ${vlanport1};mode access; access vlan 100;
    Commit Testcase

Send packet with particular mac from scapy
    [Documentation]     performing mac learning by packet injection on one server port
    ${cli}=             1.send_packet  ${4}

Verify Learning
    [Documentation]     check fdb learning
    ${cli}=             Cli    top
    ${cli}=             Cli    do show layer2 mac-address
    Should contain     ${cli}  00:11:22:33:44:55
    ${cli}=             Cli    do clear interface packet-statistics

Send Flooding packet
   [Documentation]      Send packet form other server port with same Dip as above
   ${cli}=              1.send_dmacpacket  ${10000}
   Sleep    5s

Check flooding
    [Documentation]     check Results
    ${cli}=             Cli    do show interface packet-statistics detail ${serverport2}
    Should contain     ${cli}  100
    ${cli}=             Cli    do show interface packet-statistics detail ${dut_iface2}| include "Rx 64"
    Should contain     ${cli}  100
    ${cli}=             Cli    do show interface packet-statistics detail ${vlanport1}| include "Rx 64"
    Should Not contain     ${cli}  100

Remove interface from bridge
    [Documentation]     cleanup
    ${cli}=             Cli    bridge default; no interface ${dut_iface2};no interface ${serverport2};no interface ${vlanport1};
    Commit Testcase





