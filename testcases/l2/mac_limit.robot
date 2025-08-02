*** Settings ***
Name                FDB Limit
Documentation       Check FDB limit functionality
Default Tags        Falcon 118
Library             SSHLibrary
Variables           data/l2_suite.yaml
Resource            resource/common.resource
Suite Teardown      Cleanup



*** Test Cases ***
Set a mac limit on interface and check followed by cleanup
    Switch Connection     DUT
    Write    top
    Write    bridge default;allowed-vlan add ${limit_vlan} ; vlan ${limit_vlan}
    Commit Testcase
    Write    exit;interface ${dut_iface2};mode access; access vlan ${limit_vlan};
    Write    mac limit maximum ${limit};
    Commit Testcase
    Write    do show layer2 interface brief ${dut_iface2} aware-if-mac-limit maximum
    ${cli}=    Read Until Prompt
    ${second_last_line}=    Get Second-to-Last Line    ${cli}
    ${last_int}=    Get Last Integer    ${second_last_line}
    ${is_equal}=    Evaluate    ${last_int} == ${limit}
    Should Be True    ${is_equal}
    Write    top; bridge default; interface ${dut_iface2};mac clear;
    Read Until Prompt
    Sleep    2s

    Switch Connection     SERVER
    Write    sudo python3 ${scripts_base_dir}/send_random.py ${limit_packetcount} ${server_iface} ${limit_burst_size}
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     sent
    Sleep     2s
    Switch Connection    DUT
    Write    top
    Write    do show layer2 interface brief ${dut_iface2} dynamic-fdb
    ${cli}=    Read Until Prompt
    ${second_last_line}=    Get Second-to-Last Line    ${cli}
    ${last_int}=    Get Last Integer    ${second_last_line}
    ${is_equal}=    Evaluate    ${last_int} == ${limit}
    Should Be True    ${is_equal}

*** Keywords ***
Cleanup
    Switch Connection     DUT
    Write    bridge default; no interface ${dut_iface2};
    Commit Testcase