*** Settings ***
Documentation       Test case to set up mstp on dut 2
Library             NetmikoLibrary
Library             Process
Library             1.py
Library             OperatingSystem
Resource            resource/common.resource
Default Tags        layer2, rstp
Variables           data/dut2.yaml
Suite Setup         Connect to device

*** Test Cases ***
Admin up interfaces
    Enter Config Mode
    FOR    ${port}    IN    @{physical}
        ${cli}=             Cli    interface physical ${port}; link-speed auto; admin-status up; 
    END

Add DUT Interfaces to Bridge Along with Server Side Port
    [Documentation]   add to bridge
    ${cli}=    Cli    bridge default; allowed-vlan 100-205;
    FOR    ${port}    IN    @{ports}
        ${cli}=    Cli    interface ${port}; mode trunk; trunk allowed vlan all
        Commit Testcase 
    END
    Commit Testcase
    ${cli}=             Cli    top; bridge default; interface ${dut_iface2}; mode trunk;trunk allowed vlan all;
    Commit Testcase

Set up mstp on the bridge
    [Documentation]     Setting up mstp on bridge
    ${cli}=             Cli    top;
    ${cli}=             Cli    bridge default; spanning-tree-type mstp;
    Commit Testcase
    ${cli}=             Cli    mstp; mst;
    ${cli}=             Cli    msti 1 vlans 101 interface ${mstp2} priority 0;
    Commit Testcase
    ${cli}=             Cli    msti 2 vlans 201 interface ${mstp3} priority 0;
    Commit Testcase
    ${cli}=             Cli    msti 0 interface ${mstp1} priority 0;
    Commit Testcase
    ${cli}=             Cli    top; do clear interface packet-statistics
    sleep          6s

Clear interface stat
    [Documentation]     clear interface stats before sending traffic
    ${cli}=             Cli    top 
    ${cli}=             Cli    do clear interface packet-statistics ${mstp1}
    ${cli}=             Cli    do clear interface packet-statistics ${mstp2}
    ${cli}=             Cli    do clear interface packet-statistics ${mstp3}

send packet
    [Documentation]     sending 101 vlan packet
    ${cli}=             vlan_forwarding.send_packet101  ${10000}
    Sleep    10s

checking result for vlan 101
    [Documentation]     checking packet
    ${cli}=             Cli    do show interface packet-statistics detail ${mstp2}| include "Rx 64"
    Should contain     ${cli}  100
    ${cli}=             Cli    do show interface packet-statistics detail ${mstp3}| include "Rx 64"
    Should Not Contain    ${cli}    100
    ${cli}=             Cli    do show interface packet-statistics detail ${mstp1}| include "Rx 64"
    Should Not Contain    ${cli}    100

Clear interface stat for msti 2 
    [Documentation]     clear interface stats before sending traffic
    ${cli}=             Cli    top 
    ${cli}=             Cli    do clear interface packet-statistics ${mstp1}
    ${cli}=             Cli    do clear interface packet-statistics ${mstp2}
    ${cli}=             Cli    do clear interface packet-statistics ${mstp3}

send packet
    [Documentation]     sending 201 vlan packet
    ${cli}=             vlan_forwarding.send_packet201  ${10000}
    Sleep    10s

checking result for vlan 201
    [Documentation]     checking packet
    ${cli}=             Cli    do show interface packet-statistics detail ${mstp3}| include "Rx 64"
    Should contain     ${cli}  100
    ${cli}=             Cli    do show interface packet-statistics detail ${mstp2}| include "Rx 64"
    Should Not Contain    ${cli}    100
    ${cli}=             Cli    do show interface packet-statistics detail ${mstp1}| include "Rx 64"
    Should Not Contain    ${cli}    100

Clear interface stat for msti 1 
    [Documentation]     clear interface stats before sending traffic
    ${cli}=             Cli    top 
    ${cli}=             Cli    do clear interface packet-statistics ${mstp1}
    ${cli}=             Cli    do clear interface packet-statistics ${mstp2}
    ${cli}=             Cli    do clear interface packet-statistics ${mstp3}

send packet
    [Documentation]     sending 100 vlan packet
    ${cli}=             vlan_forwarding.send_packet100  ${10000}
    Sleep    10s

checking result for vlan 100
    [Documentation]     checking packet
    ${cli}=             Cli    do show interface packet-statistics detail ${mstp1}| include "Rx 64"
    Should contain     ${cli}  100
    ${cli}=             Cli    do show interface packet-statistics detail ${mstp2}| include "Rx 64"
    Should Not Contain    ${cli}    100
    ${cli}=             Cli    do show interface packet-statistics detail ${mstp3}| include "Rx 64"
    Should Not Contain    ${cli}    100

Cleanup
    [Documentation]     cleanup mstp
    ${cli}=             Cli    top;bridge default; no spanning-tree-type mstp;
    Commit Testcase
    ${cli}=             Cli    top;bridge default; no interface ${mstp1};no interface ${mstp2};no interface ${mstp3};
    Commit Testcase
  
