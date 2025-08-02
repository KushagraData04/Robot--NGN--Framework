*** Settings ***
Name                Vlan forwarding
Documentation       check vlan tag functionality
Default Tags        Falcon 118
Library             SSHLibrary
Variables           data/l2_suite.yaml
Resource            resource/common.resource
Suite Teardown      Cleanup


*** Test Cases ***
Check trunk vlan learning on falcon 118
    Switch Connection     R5
    Write    top
    Write    bridge default; allowed-vlan add ${flood_allowed_vlan},${flood_vlan}
    Commit Testcase
    Write    interface ${serverport1}; mode trunk; trunk allowed vlan add ${flood_allowed_vlan};
    Commit Testcase 
    Switch Connection     SERVER
    Write    sudo python3 ${scripts_base_dir}/send_random_mac_with_vlan.py ${flood_packetcount} ${server_iface1} ${flood_allowed_vlan} ${flood_burst_size}
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     sent
    Sleep     10s
    Switch Connection     R5
    Write     top 
    Write     do show layer2 interface brief ${serverport1} dynamic-fdb
    ${cli}=    Read Until Prompt

    ${second_last_line}=    Get Second-to-Last Line    ${cli}
    ${last_int}=    Get Last Integer    ${second_last_line}

    ${is_greater}=    Evaluate    ${last_int} > 300
    Should Be True    ${is_greater}
    
    ${is_less}=    Evaluate    ${last_int} < 600
    Should Be True    ${is_less}
    Write     bridge default; interface ${serverport1}; mac clear;
    Commit Testcase
    Write    top    
    Switch Connection     SERVER
    Write    sudo python3 ${scripts_base_dir}/send_random_mac_with_vlan.py ${flood_packetcount} ${server_iface} ${flood_vlan} ${flood_burst_size}
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     sent
    Sleep     10s
    Switch Connection     R5
    #[Documentation]     check fdb learning
    Write     top
    Write     do show layer2 interface brief ${serverport1} dynamic-fdb
    ${cli}=    Read Until Prompt
    ${second_last_line}=    Get Second-to-Last Line    ${cli}
    ${last_int}=    Get Last Integer    ${second_last_line}
    ${is_equal}=    Evaluate    ${last_int} == 0
    Should Be True    ${is_equal}


*** Keywords ***
Cleanup
    Switch Connection    R5
    Write    bridge default; no interface ${serverport1};
    Commit Testcase