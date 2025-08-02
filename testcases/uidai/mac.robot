*** Settings ***
Name                FDB Limit
Documentation       Check FDB limit functionality
Default Tags        Falcon 118
Library             SSHLibrary
Library             OperatingSystem
Variables           data/l2_suite.yaml
Resource            resource/common.resource
# Suite Teardown      Cleanup

*** Variables ***
${sleep_duration}    10s
${sleep_dur_server}    10s
${mac_to_be_sent}    1000
${mac_burst_size}    100
${file_name}    /tmp/fdb_scale_new.txt
${iface}    physical 1/18/4
${bundle_iface}    phy-1_18_3
${bundle_id}    13

*** Test Cases ***

Test phy
    Set a mac limit on interface and check followed by cleanup    phy-1_18_4    ${server_iface}    ${iface}

Test bundle
    Switch Connection    R5
    Write    top; interface bundle ${bundle_id}; port ${bundle_iface}; mode loadbalance; admin-status up
    Commit Testcase
    Set a mac limit on interface and check followed by cleanup    bundle-${bundle_id}    ${server_iface1}    bundle ${bundle_id}


*** Keywords ***
Set a mac limit on interface and check followed by cleanup
    [Arguments]    ${dut_iface2}    ${server_iface}    ${iface}
    Create File  path=${file_name}  content=FDB scale testing\n
    # Sleep    ${sleep_duration}
    Append To File    path=${file_name}  content=Slept ${sleep_duration}\n\n
    Switch Connection    R5
    Write    bridge default; allowed-vlan add ${limit_vlan} ; vlan ${limit_vlan}; mac limit maximum ${limit};
    Commit Testcase
    Write      exit;interface ${dut_iface2};mode access; access vlan ${limit_vlan};
    Write    mac limit maximum ${limit};
    Commit Testcase

    FOR  ${i}   IN RANGE   1    11
        Switch Connection    R5
        Write    top
        Append To File    path=${file_name}  content=Iteration ${i}\n\n
        Write    top; bridge default; interface ${dut_iface2}; mac clear;
        # Sleep    ${sleep_duration}
        Append To File    path=${file_name}  content= Cleared MAC and slept ${sleep_duration}\n

        Switch Connection     SERVER
        # Write    sudo python3 ${scripts_base_dir}/send_random.py ${mac_to_be_sent} ${server_iface} ${mac_burst_size}
        Write    sudo python3 ${scripts_base_dir}/send_random.py ${mac_to_be_sent} ${server_iface} ${mac_burst_size} 
        ${cli}=     Read Until Prompt
        Should Contain     ${cli}     sent

        Switch Connection    R5
        Sleep    ${sleep_dur_server}
        Append To File    path=${file_name}  content= Sent ${mac_to_be_sent} random MAC\n
        # Write    do show system resource-table | include FDB
        Write    do show layer2 vlan brief 400
        # ${cli}=    Read Until Prompt    strip_prompt= ${True}
        ${cli1}=    Read Until Prompt
        Append To File    path=${file_name}  content= ${cli1}\n\n
        # ${value}=    Get Third Last Integer    ${cli}
        # ${is_equal}=    Evaluate    ${value} >= ${limit_packetcount}
        # Run Keyword And Continue On Failure    Should Be True    ${is_equal}
        # Run Keyword If    not ${is_equal}    Append To File    path=${file_name}  content= Condition failed: ${value} is less than ${limit_packetcount}\n
        Write    top; interface ${iface}; admin-status down;
        Commit Testcase
        Commit Testcase
        Write    top; interface ${iface}; admin-status up
        Commit Testcase
        Commit Testcase
        check state    ${dut_iface2}
        # Write    top;
        # Write    top; bridge default; interface ${dut_iface2};mac clear;
        # Sleep    ${sleep_duration}
        # Append To File    path=${file_name}  content= Cleared MAC and slept ${sleep_duration}\n

        # Switch Connection     SERVER
        # Write    sudo python3 ${scripts_base_dir}/send_serial_mac.py ${mac_to_be_sent} ${server_iface} ${mac_burst_size}
        # ${cli}=     Read Until Prompt
        # Should Contain     ${cli}     sent
        # Sleep     ${sleep_dur_server}
        # Switch Connection    R5
        # Write    top
        # Append To File    path=${file_name}  content= Sent ${limit_packetcount} Serial increasing MAC\n

        # Write      do show system resource-table | include FDB
        # ${cli}=    Read Until Prompt    strip_prompt= ${True}
        # Append To File    path=${file_name}  content= ${cli}\n\n
        # ${value}=    Get Third Last Integer    ${cli}
        # ${is_equal}=    Evaluate    ${value} >= ${limit_packetcount}
        # Run Keyword And Continue On Failure    Should Be True    ${is_equal}
        # Run Keyword If    not ${is_equal}    Append To File    path=${file_name}  content= Condition failed: ${value} is less than ${limit_packetcount}\n

        ${i}=    Evaluate    ${i} + 1

    END



Cleanup
    Switch Connection     R5
    # Write    bridge default; no interface ${dut_iface2};
    # Commit Testcase