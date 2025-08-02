*** Settings ***
Name                BVI
Documentation       Check BVI feature
Default Tags        Falcon 118
Library             SSHLibrary
Library             OperatingSystem
Variables           data/l2_suite.yaml
Resource            resource/monit.resource
Resource            resource/common.resource
Suite Teardown      Cleanup

*** Variables ***
${dut_iface1}    bundle-11
${dut_iface2}    bundle-15

${cli_dut_iface1}    bundle 11
${cli_dut_iface2}    bundle 15

*** Test Cases ***

Create bundle interfaces
    Switch Connection     DUT
    Write    interface ${cli_dut_iface1} 
    Write    port phy-1_1_1
    Write    admin-status up
    Write    interface ${cli_dut_iface2} 
    Write    port phy-1_2_1
    Write    admin-status up
    Commit Testcase

Add first member, enable IRB on vlan and check oper-status
    Switch Connection     DUT

    Write    top; bridge default;
    Write    allowed-vlan add ${bvi_oper_vlan}
    Write    interface ${dut_iface1}; mode trunk; trunk allowed vlan add ${bvi_oper_vlan}
   
    # Create bvi
    Write    top; bridge default;
    Write    vlan ${bvi_oper_vlan}; irb enable;top;
    Write    interface subif bvi-1.${bvi_oper_vlan}; admin-status up;
    Write    ipv4 address 10.12.34.1 prefix 24;

    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

Remove vlan form first member
    Write    top; bridge default;
    Write    interface ${dut_iface1}; trunk allowed vlan remove ${bvi_oper_vlan}
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     down

Add back vlan on first member
    Write    top; bridge default;
    Write    interface ${dut_iface1}; trunk allowed vlan add ${bvi_oper_vlan}
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

Remove first member
    Write    top; bridge default;
    Write    no interface ${dut_iface1};
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     down

Add back first member
    Write    top; bridge default;
    Write    interface ${dut_iface1}; mode trunk; trunk allowed vlan add ${bvi_oper_vlan}
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

Admin down vlan interface
    Write    top;
    Write    interface subif bvi-1.${bvi_oper_vlan}; admin-status down;
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     down

Admin up vlan interface
    Write    top;
    Write    interface subif bvi-1.${bvi_oper_vlan}; admin-status up;
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

Add second member
    Write    top; bridge default;
    Write    interface ${dut_iface2}; mode trunk; trunk allowed vlan add ${bvi_oper_vlan}
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

Remove second member
    Write    top; bridge default;
    Write    no interface ${dut_iface2};
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

2nd Remove first member
    Write    top; bridge default;
    Write    no interface ${dut_iface1};
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     down

2nd Admin down vlan interface
    Write    top;
    Write    interface subif bvi-1.${bvi_oper_vlan}; admin-status down;
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     down

2nd Admin up vlan interface
    Write    top;
    Write    interface subif bvi-1.${bvi_oper_vlan}; admin-status up;
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     down

2nd Add first member
    Write    top; bridge default;
    Write    interface ${dut_iface1}; mode trunk; trunk allowed vlan add ${bvi_oper_vlan}
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

Admin down first member
    Write    interface ${cli_dut_iface1} admin-status down 
    Commit Testcase
    Sleep    5s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     down

Admin up first member
    Write    interface ${cli_dut_iface1} admin-status up 
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

2nd Add second member
    Write    top; bridge default;
    Write    interface ${dut_iface2}; mode trunk; trunk allowed vlan add ${bvi_oper_vlan}
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

Admin down second member
    Write    interface ${cli_dut_iface2} admin-status down 
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

Admin up second member
    Write    interface ${cli_dut_iface2} admin-status up 
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

2nd Admin down first member
    Write    interface ${cli_dut_iface1} admin-status down 
    Commit Testcase
    Sleep    5s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

2nd Admin down second member
    Write    interface ${cli_dut_iface2} admin-status down 
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     down

2nd Admin up first member
    Write    interface ${cli_dut_iface1} admin-status up 
    Commit Testcase
    Sleep    2s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

*** Keywords ***
Cleanup
    Switch Connection    DUT
    # Delete bvi
    Write    top; bridge default;
    Write    no interface ${dut_iface1};
    Write    no interface ${dut_iface2};
    Write    no vlan ${bvi_oper_vlan};
    Commit Testcase
