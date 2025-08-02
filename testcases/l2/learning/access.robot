*** Settings ***
Name                Access Vlan
Documentation       check learning on access vlan 
Default Tags        Falcon 118
Library             SSHLibrary
Variables           data/l2_suite.yaml
Resource            resource/common.resource
Suite Teardown      Cleanup


*** Test Cases ***
Check trunk vlan learning on falcon 118
    Switch Connection     DUT
    Write    top
    Write    bridge default; allowed-vlan add ${learning_allowed_vlan}; vlan ${learning_allowed_vlan}
    Commit Testcase
    Write    interface ${dut_iface2}; mode access; access vlan ${learning_allowed_vlan};
    Commit Testcase 
    Switch Connection     SERVER
    Write    sudo python3 ${scripts_base_dir}/send_random_mac_with_vlan.py ${learning_packetcount} ${server_iface2} ${learning_allowed_vlan} ${learning_burst_size}
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     sent
    Sleep     10s
    Switch Connection     DUT
    Write     top
    Write     do show layer2 interface brief ${dut_iface2} dynamic-fdb
    ${cli}=    Read Until Prompt

    ${second_last_line}=    Get Second-to-Last Line    ${cli}
    ${last_int}=    Get Last Integer    ${second_last_line}

    ${is_greater}=    Evaluate    ${last_int} > 300
    Should Be True    ${is_greater}
    
    ${is_less}=    Evaluate    ${last_int} < 600
    Should Be True    ${is_less}

*** Keywords ***
Cleanup
    Switch Connection    DUT
    Write    bridge default; no interface ${dut_iface2};
    Commit Testcase