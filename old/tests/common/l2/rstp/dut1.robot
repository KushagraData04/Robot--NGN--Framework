*** Settings ***
Documentation       Test case to set up rstp
Library             NetmikoLibrary
Library             Process
Library             OperatingSystem
Resource            resource/common.resource
Default Tags        layer2, rstp
Variables           data/dut1.yaml
Suite Setup         Connect to device

*** Test Cases ***

Admin up interfaces
    Enter Config Mode
    [Documentation]    Admin up interface between 2 DUT
    Enter Config Mode
    FOR    ${port}    IN    @{physical}
        ${cli}=             Cli    interface physical ${port}; link-speed auto; admin-status up;
        Commit Testcase
    END

Add DUT Interfaces to Bridge Along with Server Side Port
    [Documentation]    Admin up port and add to bridge
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
    ${cli}=             Cli    rstp; priority 0;
    Commit Testcase
    ${cli}=             Cli    interface ${rootport}; priority 0;
    Commit Testcase
    sleep          6s


Check Discarding State on root side of Spanning Tree
   # [Documentation]    Check interface state
    ${cli}=    Cli    top
    FOR    ${port}    IN    @{ports}
        ${interface}=    Set Variable    ${port}
        ${cli}=    Cli    do show spanning-tree interface ${interface}
        Should Not Contain    ${cli}    Discarding
    END
    

