*** Settings ***
Documentation       Test case to verify Mac Aging timer
Library             NetmikoLibrary
Library             Process
Library             1.py
Library             OperatingSystem
Resource            resource/common.resource
Default Tags        layer2
Variables           data/dut2.yaml
Suite Setup         Connect to device

*** Test Cases ***

Add server port to bridge
    Enter Config Mode
    [Documentation]     Add the server side port to bridge and clear mac learnt
    # Configure the bridge with two ports
    ${cli}=             Cli    bridge default;allowed-vlan add 100,200 ; vlan 100; vlan 200;
    ${cli}=             Cli    exit;interface ${dut_iface2};mode access; access vlan 100;
    Commit Testcase
    ${cli}=             Cli    mac clear 

Set ageing time
    [Documentation]     Set aging time to 10 seconds
    ${cli}=             Cli    top
    ${cli}=             Cli    l2 aging-time 10;
    Commit Testcase
   
Send packet with particular mac from scapy
    [Documentation]     Send a packet with a mac for server to dut for learning
    ${cli}=             1.send_packet  ${4}

FALCON -118 Verify packet
    [Documentation]     check mac learnt both before and after an interval of 20 seconds
    ${cli}=             Cli    do show layer2 mac-address
    Should contain     ${cli}  00:11:22:33:44:55
    Sleep  20s
    ${cli}=             Cli    do show layer2 mac-address
    Should Not contain     ${cli}  00:11:22:33:44:55

Remove interface from bridge
    [Documentation]     delete interface from bridge
    ${cli}=             Cli    bridge default; no interface ${dut_iface2};
    ${cli}=             Cli    top; l2 aging-time 300;
    Commit Testcase
