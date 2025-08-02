*** Settings ***
Name               FDB Aging
Documentation      Check FDB aging time feature
Default Tags       Aging
Library            SSHLibrary
Variables          data/l2_suite.yaml
Resource           resource/common.resource
Suite Teardown     Cleanup


*** Test Cases ***
Test to check mac aging in falcon 118 
    Switch Connection     R5
    Write    top
    Write    bridge default;allowed-vlan add ${aging_vlan}
    Write    vlan ${aging_vlan};
    Commit Testcase
    Write    exit;interface ${serverport1};mode access; access vlan ${aging_vlan};
    Commit Testcase 
    Write    mac clear
    Write    top
    Write    l2 aging-time ${aging_time}
    Commit Testcase
    Switch Connection    SERVER
    Write    sudo python3 krishna/send_serial_mac.py ${aging_packetcount} ${server_iface1} ${aging_burst_size}
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     sent
    Sleep    1s
    Switch Connection    R5
    Write     do show layer2 vlan brief ${aging_vlan} dynamic-fdb
    ${cli}=    Read Until Prompt
    ${second_last_line}=    Get Second-to-Last Line    ${cli}
    ${last_int}=    Get Last Integer    ${second_last_line}

    ${is_greater}=    Evaluate    ${last_int} > 300
    Should Be True    ${is_greater}
    
    ${is_less}=    Evaluate    ${last_int} < 600
    Should Be True    ${is_less}


    ${wait_for_aging}=    Evaluate    ${aging_time} * 2
    Sleep    ${wait_for_aging}
    Write     do show layer2 vlan brief ${aging_vlan} dynamic-fdb
    ${cli}=    Read Until Prompt
    ${second_last_line}=    Get Second-to-Last Line    ${cli}
    ${last_int}=    Get Last Integer    ${second_last_line}
    ${is_equal}=    Evaluate    ${last_int} == 0
    Should Be True    ${is_equal}

*** Keywords ***
Cleanup
    Switch Connection    R5
    # Write    bridge default; no interface ${serverport1};
    Write    top; l2 aging-time 300
    Commit Testcase

