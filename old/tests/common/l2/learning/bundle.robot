*** Settings ***
Documentation       Test case to verify mac learning on bundle
Library             NetmikoLibrary
Library             Process
Library             1.py
Library             OperatingSystem
Resource            resource/common.resource
Default Tags        layer2
Variables           data/dut2.yaml
Suite Setup         Connect to device

*** Test Cases ***

Create bundle and adding to bridge
    Enter Config Mode
    [Documentation]     Create bundle and add to bridge     
    ${cli}=             Cli    interface bundle ${bundleid};port ${dut_iface2}; mode loadbalance; admin-status up;
    Commit Testcase
    ${cli}=             Cli    top
    ${cli}=             Cli    bridge default;allowed-vlan add 100,200 ; vlan 100; vlan 200;
    Commit Testcase
    ${cli}=             Cli    interface bundle-${bundleid};mode access; access vlan 100;
    Commit Testcase

Send packet from scapy
    [Documentation]     inject packet with mac "00:11:22:33:44:55"
    ${cli}=             1.send_packet  ${4}

Verify packet
    [Documentation]     check fdb learning
    ${cli}=             Cli    top
    ${cli}=             Cli    do show layer2 mac-address
    Should contain     ${cli}  00:11:22:33:44:55

Delete bundle interface
    [Documentation]    Delete bundle interface
    ${cli}=             Cli    bridge default; no interface bundle-${bundleid};
    Commit Testcase
    ${cli}=             Cli    top; no interface bundle ${bundleid};
    Commit Testcase

