*** Settings ***
Name                SPAN
Documentation       Check SPAN feature
Default Tags        Falcon 118
Library             SSHLibrary
Variables           data/l2_suite.yaml
Resource            resource/erspan.resource
Resource            resource/common.resource
Suite Teardown      Cleanup


*** Test Cases ***
Test to check span in falcon 118
    Switch Connection    DUT
    Write    top
    Write    mirroring session span type local
    Write    mirror-destination interface ${dut_iface1}; admin-status up;
    Write    mirror-source interface ${dut_iface2} direction ${span_direction};
    Commit Testcase 
    Write    do clear interface packet-statistics
    Switch Connection    SERVER
    Write    sudo python3 ${scripts_base_dir}/send_random.py ${span_packetcount} ${server_iface2} ${span_burst_size}
    ${cli}=    Read Until Prompt
    Should Contain    ${cli}    sent

    Switch Connection    DUT
    Sleep    5s
    Write    do show interface packet-statistics brief ${dut_iface1} tx-pkts
    ${output}=    Read Until Prompt
    Should Contain    ${output}    ${span_pack}
    Write    do show interface packet-statistics brief ${dut_iface2} rx-pkts
    ${output}=    Read Until Prompt
    Should Contain    ${output}    ${span_pack}

    
 

*** Keywords ***
Cleanup
    Switch Connection     DUT
    Write    top; no mirroring session span
    Commit Testcase
    
    