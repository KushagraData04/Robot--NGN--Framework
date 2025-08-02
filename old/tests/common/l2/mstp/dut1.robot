*** Settings ***
Documentation       Test case to set up mstp on dut 1
Library             NetmikoLibrary
Library             Process
Library             OperatingSystem
Resource            resource/common.resource
Default Tags        layer2, mstp
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
    [Documentation]    Add port to bridge
    ${cli}=    Cli    bridge default; allowed-vlan 100-205;
    FOR    ${port}    IN    @{ports}
        ${cli}=    Cli    interface ${port}; mode trunk; trunk allowed vlan all
        Commit Testcase 
    END
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

