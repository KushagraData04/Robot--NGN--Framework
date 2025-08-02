*** Settings ***
Name                BVI
Documentation       Check BVI feature
Default Tags        Falcon 118
Library             SSHLibrary
Library             OperatingSystem
Variables           data/l2-2-dut_suite.yaml
Resource            resource/monit.resource
Resource            resource/common.resource
Suite Teardown      Cleanup

** Variables ***
# Changing value of below variables so as that testcase
# runs on bundle interface.
${dut_iface1}    bundle-11
${dut_iface2}    bundle-15

${cli_dut_iface1}    bundle 11
${cli_dut_iface2}    bundle 15

*** Test Cases ***

Create bundle interfaces
    Switch Connection     DUT1
    Write    interface ${cli_dut_iface1} 
    Write    port phy-1_13_1
    Write    admin-status up
    Write    interface ${cli_dut_iface2} 
    Write    port phy-1_12_1
    Write    admin-status up
    Commit Testcase

Add first member, enable IRB on vlan and check oper-status
    Switch Connection     DUT1

    Write    top; bridge default;
    Write    allowed-vlan add ${bvi_oper_vlan}
    Write    interface ${dut_iface1}; mode trunk; trunk allowed vlan add ${bvi_oper_vlan}
   
    # Create bvi
    Write    top; bridge default;
    Write    vlan ${bvi_oper_vlan}; irb enable;top;
    Write    interface subif bvi-1.${bvi_oper_vlan}; admin-status up;
    Write    ipv4 address 10.12.34.1 prefix 24;

    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

Create VNI on DUT2 for later use
    Switch Connection     DUT2

    Write    top; bridge default;
    Write    allowed-vlan add ${bvi_oper_vlan}
    Write    interface ${dut_iface1}; mode trunk; trunk allowed vlan add ${bvi_oper_vlan}
   
    # Create bvi
    Write    top; bridge default;
    Write    vlan ${bvi_oper_vlan}; irb enable;top;
    Write    interface subif bvi-1.${bvi_oper_vlan}; admin-status up;
    Write    ipv4 address 10.12.34.1 prefix 24;
    VNI create DUT2

Remove vlan form first member
    Switch Connection    DUT1
    Pre-test sleep    
    Write    top; bridge default;
    Write    interface ${dut_iface1}; trunk allowed vlan remove ${bvi_oper_vlan}
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     down
    Create VNI and check vlan oper with    up
    Delete VNI and check vlan oper with    down

Add back vlan on first member
    Pre-test sleep
    Write    top; bridge default;
    Write    interface ${dut_iface1}; trunk allowed vlan add ${bvi_oper_vlan}
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up
    Create VNI and check vlan oper with    up
    Delete VNI and check vlan oper with    up

Remove first member
    Pre-test sleep
    Write    top; bridge default;
    Write    no interface ${dut_iface1};
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     down
    Create VNI and check vlan oper with    up
    Delete VNI and check vlan oper with    down

Add back first member
    Pre-test sleep
    Write    top; bridge default;
    Write    interface ${dut_iface1}; mode trunk; trunk allowed vlan add ${bvi_oper_vlan}
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up


Admin down vlan interface
    Pre-test sleep
    Write    top;
    Write    interface subif bvi-1.${bvi_oper_vlan}; admin-status down;
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     down
    Create VNI and check vlan oper with    down
    Delete VNI and check vlan oper with    down

Admin up vlan interface
    Pre-test sleep
    Write    top;
    Write    interface subif bvi-1.${bvi_oper_vlan}; admin-status up;
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up


Add second member
    Pre-test sleep
    Write    top; bridge default;
    Write    interface ${dut_iface2}; mode trunk; trunk allowed vlan add ${bvi_oper_vlan}
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up
    Create VNI and check vlan oper with    up
    Delete VNI and check vlan oper with    up

Remove second member
    Pre-test sleep
    Write    top; bridge default;
    Write    no interface ${dut_iface2};
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

2nd Remove first member
    Pre-test sleep
    Write    top; bridge default;
    Write    no interface ${dut_iface1};
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     down
    Create VNI and check vlan oper with    up
    Delete VNI and check vlan oper with    down

2nd Admin down vlan interface
    Pre-test sleep
    Write    top;
    Write    interface subif bvi-1.${bvi_oper_vlan}; admin-status down;
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     down
    Create VNI and check vlan oper with    down
    Delete VNI and check vlan oper with    down

2nd Admin up vlan interface
    Pre-test sleep
    Write    top;
    Write    interface subif bvi-1.${bvi_oper_vlan}; admin-status up;
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     down

2nd Add first member
    Pre-test sleep
    Write    top; bridge default;
    Write    interface ${dut_iface1}; mode trunk; trunk allowed vlan add ${bvi_oper_vlan}
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up
    Create VNI and check vlan oper with    up
    Delete VNI and check vlan oper with    up

Admin down first member
    Pre-test sleep
    Write    interface ${cli_dut_iface1} admin-status down 
    Commit Testcase
    Sleep    10s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     down
    Create VNI and check vlan oper with    up
    Delete VNI and check vlan oper with    down

Admin up first member
    Pre-test sleep
    Write    interface ${cli_dut_iface1} admin-status up 
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

2nd Add second member
    Pre-test sleep
    Write    top; bridge default;
    Write    interface ${dut_iface2}; mode trunk; trunk allowed vlan add ${bvi_oper_vlan}
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

Admin down second member
    Pre-test sleep
    Write    interface ${cli_dut_iface2} admin-status down 
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

Admin up second member
    Pre-test sleep
    Write    interface ${cli_dut_iface2} admin-status up 
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up

2nd Admin down first member and leave VNI created
    Pre-test sleep
    Write    interface ${cli_dut_iface1} admin-status down 
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up
    Create VNI and check vlan oper with    up

2nd Admin down second member
    Pre-test sleep
    Write    interface ${cli_dut_iface2} admin-status down 
    Commit Testcase
    Sleep    10s
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up
    Delete VNI and check vlan oper with    down

2nd Admin up first member
    Pre-test sleep
    Write    interface ${cli_dut_iface1} admin-status up 
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     up
    
    # Admin-down to make vlan down
    Write    interface ${cli_dut_iface1} admin-status down
    Commit Testcase
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     down

Toggle vlan oper-status on basis of VNI multiple times
    Create VNI and check vlan oper with    up
    Delete VNI and check vlan oper with    down
    Create VNI and check vlan oper with    up
    Delete VNI and check vlan oper with    down
    Create VNI and check vlan oper with    up
    Delete VNI and check vlan oper with    down
    Create VNI and check vlan oper with    up
    Delete VNI and check vlan oper with    down

*** Keywords ***

Cleanup
    Switch Connection    DUT1
    # Delete bvi
    Write    top; bridge default;
    Write    no interface ${dut_iface1};
    Write    no interface ${dut_iface2};
    Write    no vlan ${bvi_oper_vlan};
    Write    allowed-vlan remove ${bvi_oper_vlan};
    Commit Testcase
    VNI delete DUT2

Wait for DUT oper-status changes
    Sleep    15s

Pre-test sleep
    Sleep    1s

VNI create DUT1
    Switch Connection    DUT1
    Write    interface vxlan 1
    Write    vni 11234 vlan 1234
    Write    gateway-mac-mode anycast-gateway
    Commit Testcase

VNI create DUT2
    Switch Connection    DUT2
    Write    interface vxlan 1
    Write    vni 11234 vlan 1234
    Write    gateway-mac-mode anycast-gateway
    Commit Testcase

VNI delete DUT1
    Switch Connection    DUT1
    Write    interface vxlan 1
    Write    no vni 11234
    Commit Testcase

VNI delete DUT2
    Switch Connection    DUT2
    Write    interface vxlan 1
    Write    no vni 11234
    Commit Testcase

Create VNI and check vlan oper with
   [Arguments]    ${param1}
    #Create VNI on DUT1
    VNI create DUT1
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     ${param1}

Delete VNI and check vlan oper with
   [Arguments]    ${param1}
    #Delete VNI on DUT1
    VNI delete DUT1
    Wait for DUT oper-status changes
    Write    do show interface configuration brief bvi-1.${bvi_oper_vlan} oper-status
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     ${param1}