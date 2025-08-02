*** Settings ***
Documentation       Test case to verify packet vlan forwarding between bridge ports
Library             NetmikoLibrary
Library             Process
Library             vlan_forwarding.py
Library             OperatingSystem
Resource            resource/common.resource
Default Tags        layer2
Variables           data/dut2.yaml
Suite Setup         Connect to device

*** Test Cases ***
intial configuration
    Enter Config Mode
    [Documentation]     add server side port to bridge
    # Configure the bridge with two ports
    ${cli}=             Cli    bridge default;allowed-vlan add 100,200 ; vlan 100; vlan 200; 
    Commit Testcase
    ${cli}=             Cli    top; bridge default; interface ${dut_iface2};mode trunk; trunk allowed vlan add 100,200;
    Commit Testcase


Add two interface for vlan traffic check
    [Documentation]     admin up port and add to bridge
    # Configure the bridge with two ports
    ${cli}=             Cli    top
    FOR    ${port}    IN    @{physical}
        ${cli}=             Cli    interface physical ${port}; link-speed auto; admin-status up; 
        Commit Testcase
    END
    ${cli}=             Cli    top; bridge default;
    ${cli}=             Cli    interface ${vlanport1}; mode access; access vlan 100;
    ${cli}=             Cli    interface ${vlanport2}; mode access; access vlan 200;
    Commit Testcase

Clear interface stat
    [Documentation]     clear interface stats before sending traffic
    ${cli}=             Cli    top 
    ${cli}=             Cli    do clear interface packet-statistics ${dut_iface2}
    ${cli}=             Cli    do clear interface packet-statistics ${vlanport1}
    ${cli}=             Cli    do clear interface packet-statistics ${vlanport2}

send packet
    [Documentation]     sending 100 vlan packet
    ${cli}=             vlan_forwarding.send_packet100  ${10000}
    Sleep    10s

checking result for vlan 100
    [Documentation]     checking packet
    ${cli}=             Cli    do show interface packet-statistics detail ${vlanport1}| include "Rx 64"
    Should contain     ${cli}  100
    ${cli}=             Cli    do show interface packet-statistics detail ${vlanport2}| include "Rx 64"

    Should Not Contain    ${cli}    100

#Clear interface stat
#    [Documentation]     clear interface stats before sending traffic
#    ${cli}=             Cli    top
#    ${cli}=             Cli    do clear interface packet-statistics ${dut_iface2}
#    ${cli}=             Cli    do clear interface packet-statistics ${vlanport1}
#    ${cli}=             Cli    do clear interface packet-statistics ${vlanport2}
#
#send packet
#    [Documentation]     sending 200 vlan packet
#    ${cli}=             vlan_forwarding.send_packet200  ${10000}
#    Sleep   10s
#
#checking result for vlan 200
#    [Documentation]     checking packet
#    ${cli}=             Cli    do show interface packet-statistics detail ${vlanport2}| include "Rx 64"
#    Should contain     ${cli}  100
#    ${cli}=             Cli    do show interface packet-statistics detail ${vlanport1}| include "Rx 64"
#    Should Not Contain    ${cli}    100

Cleanup
    [Documentation]     setting hostname back to original 
    ${cli}=             Cli    bridge default;no interface ${vlanport1};no interface ${vlanport2}; no interface ${dut_iface2}; commit; top; 
    ${cli}=             Cli    no system cli prompt2;
    Commit Testcase



