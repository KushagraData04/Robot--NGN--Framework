*** Settings ***
Documentation       Test case to verify Mac limit on port
Library             NetmikoLibrary
Library             Process
Library             1.py
Library             OperatingSystem
Default Tags        layer2
Resource            resource/common.resource
Variables           data/dut2.yaml
Suite Setup         Connect to device

*** Test Cases ***

Add server port to bridge and set mac limit to 25
    Enter Config Mode
    [Documentation]     Add server port to bridge and set mac limit to 25
    ${cli}=             Cli    bridge default;allowed-vlan add 100,200 ; vlan 100; vlan 200;
    Commit Testcase
    ${cli}=             Cli    exit;interface ${dut_iface2};mode access; access vlan 100;
    Commit Testcase
    ${cli}=    Cli    mac limit maximum 25;
    Commit Testcase
    ${cli}=    Cli    do show running-config bridge interface ${dut_iface2} 
    Should Contain Any    ${cli}    25
    ${cli}=    Cli    top; bridge default; interface ${dut_iface2};mac clear; 

Send 100 differnt mac packet
   [Documentation]     Send packet with 100 different mac

   ${cli}=          1.send_mac   ${100}
   Sleep   5s
Check MAC Stats
    [Documentation]     check number of mac learnt
    ${cli}=    Cli    top
    ${cli}=    Cli    do show layer2 mac-address | include ${dut_iface2} | count
    Should Contain Any    ${cli}    25


Remove interface from bridge
    [Documentation]     delete interface from bridge
    ${cli}=             Cli    bridge default; no interface ${dut_iface2};
    Commit Testcase


