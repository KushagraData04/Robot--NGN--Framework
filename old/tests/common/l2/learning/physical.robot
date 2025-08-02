*** Settings ***
Documentation       Test case to verify Mac learning on physical port
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
    [Documentation]     Configure the bridge with port
    ${cli}=             Cli    bridge default;allowed-vlan add 100,200 ; vlan 100; vlan 200;
    Commit Testcase
    ${cli}=             Cli    exit;interface ${dut_iface2};mode access; access vlan 100;
    Commit Testcase 

Send packet with particular mac from scapy
    [Documentation]     Send packet
    ${cli}=             1.send_packet  ${4}

Verify packet
    [Documentation]     check fdb learning
    ${cli}=             Cli    top
    ${cli}=             Cli    do show layer2 mac-address
    Should contain     ${cli}  00:11:22:33:44:55

Remove interface from bridge
    [Documentation]     delete interface from bridge
    ${cli}=             Cli    bridge default; no interface phy-1_19_1;
    Commit Testcase

