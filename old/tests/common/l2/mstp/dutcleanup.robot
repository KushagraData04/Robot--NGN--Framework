*** Settings ***
Documentation       Test case to cleanup mstp on dut 1
Library             NetmikoLibrary
Library             Process
Library             OperatingSystem
Resource            resource/common.resource
Default Tags        layer2, rstp
Variables           data/dut1.yaml
Suite Setup         Connect to device

*** Test Cases ***
Check dut 1 side statistics
    [Documentation]     checking packet
    ${cli}=             Cli    top;do show interface packet-statistics detail ${mstp3}| include "Rx 64"
    Should contain     ${cli}  100
    ${cli}=             Cli    do show interface packet-statistics detail ${mstp2}| include "Rx 64"
    Should Contain    ${cli}    100
    ${cli}=             Cli    do show interface packet-statistics detail ${mstp1}| include "Rx 64"
    Should Contain    ${cli}    100

Cleanup
    [Documentation]     cleanup mstp
    ${cli}=             Cli    top;bridge default; no spanning-tree-type mstp;
    Commit Testcase
    ${cli}=             Cli    top;bridge default; no interface ${mstp1};no interface ${mstp2};no interface ${mstp3};
    Commit Testcase

