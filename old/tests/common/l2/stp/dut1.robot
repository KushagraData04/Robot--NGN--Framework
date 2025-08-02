*** Settings ***
Documentation       Test case to set up stp
Library             NetmikoLibrary
Library             Process
Library             OperatingSystem
Resource            resource/common.resource
Default Tags        layer2, stp
Variables           data/dut1.yaml
Suite Setup         Connect to device

*** Test Cases ***

Admin up interfaces
    Enter Config Mode
    [Documentation]    Admin up interface between 2 DUT
    Enter Config Mode
    FOR    ${port}    IN    @{physical}
        ${cli}=             Cli    interface physical ${port}; link-speed auto; admin-status up;
    END

Add DUT Interfaces to Bridge Along with Server Side Port
    [Documentation]    Admin up port and add to bridge
    ${cli}=    Cli    bridge default; allowed-vlan 100-130;
    FOR    ${port}    IN    @{ports}
        ${cli}=    Cli    interface ${port}; mode access; access vlan 100
    END
    Commit Testcase

Set up stp on the bridge
    [Documentation]     Setting up stp on bridge
    ${cli}=             Cli    top;
    ${cli}=             Cli    bridge default; spanning-tree-type stp;
    Commit Testcase
    ${cli}=             Cli    stp; priority 0;
    ${cli}=             Cli    interface ${rootport}; priority 0;
    Commit Testcase
    sleep          20s

Check Edge State of Spanning Tree Interfaces
   # [Documentation]    Check interface state
    ${cli}=    Cli    config
    FOR    ${port}    IN    @{ports}
        ${interface}=    Set Variable    ${port}
        ${cli}=    Cli    do show spanning-tree interface ${interface}
    END

Check Discarding State on root side of Spanning Tree
    ${cli}=    Cli    top
    FOR    ${port}    IN    @{ports}
        ${interface}=    Set Variable    ${port}
        ${cli}=    Cli    do show spanning-tree interface ${interface}
        Should Not Contain    ${cli}    Blocking
    END
    

