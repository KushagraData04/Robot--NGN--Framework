*** Settings ***
Documentation       Test case to set up and test rstp on dut2
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
        Commit Testcase
    END

Add DUT Interfaces to Bridge Along with Server Side Port
    [Documentation]    Admin up port and add to bridge
    ${cli}=    Cli    top;
    ${cli}=    Cli    bridge default; allowed-vlan 100-130;
    FOR    ${port}    IN    @{ports}
        ${cli}=    Cli    interface ${port}; mode access; access vlan 100
    END
    Commit Testcase
Set up rstp on the bridge
    [Documentation]     Setting up rstp on bridge
    ${cli}=             Cli    top;
    ${cli}=             Cli    bridge default; spanning-tree-type rstp;
    Commit Testcase
    ${cli}=             Cli    rstp; priority 4096;
    Commit Testcase
    sleep          6s

Check Edge State of Spanning Tree Interfaces
   # [Documentation]    Check interface state
    FOR    ${port}    IN    @{ports}
        ${interface}=    Set Variable    ${port}
        ${cli}=    Cli    do show spanning-tree interface ${interface}
        Should Not Contain    ${cli}    Yes
    END

Check Discarding State on root side of Spanning Tree
   # [Documentation]    Check interface state
    FOR    ${port}    IN    @{ports2}
        ${interface}=    Set Variable    ${port}
        ${cli}=    Cli    do show spanning-tree interface ${interface}
        Should Contain    ${cli}    Alternate
    END

Check Alternate State on non root side of Spanning Tree
   # [Documentation]    Check interface state
    FOR    ${port}    IN    @{ports2}
        ${interface}=    Set Variable    ${port}
        ${cli}=    Cli    do show spanning-tree interface ${interface}
        Should Contain    ${cli}    Discarding
    END
    ${cli}=    Cli    do clear interface packet-statistics
Send traffic to check
    [Documentation]     sending 100 vlan packet 
    ${cli}=             1.send_packet100  ${10000}
    sleep   4s

verify packet sent
    [Documentation]     checking packet
    ${cli}=             Cli    top;do show interface packet-statistics detail ${dut_iface2}| include "Rx 64"
    Should contain     ${cli}  100
    FOR    ${port}    IN    @{ports2}
        ${interface}=    Set Variable    ${port}
        ${cli}=    Cli    do show interface packet-statistics detail ${interface}
        Should Not Contain    ${cli}    100
    END
    ${cli}=    Cli    do show interface packet-statistics detail ${vlanport1}
    Should contain     ${cli}  100

Cleanup RSTP
    ${cli}=    Cli    top; bridge default; no spanning-tree-type rstp;
    FOR    ${port}    IN    @{ports}
        ${cli}=    Cli    no interface ${port};
    END
    Commit Testcase
    

