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
${sleep_dur_server}    5s
${mac_to_be_sent}    1000
${mac_burst_size}    250
${file_name}    /tmp/fdb_clash.txt


*** Test Cases ***
Set a mac limit on interface and check followed by cleanup

    Create File  path=${file_name}  content=FDB scale testing\n
    # Sleep    ${sleep_duration}
    Append To File    path=${file_name}  content=Slept ${sleep_duration}\n\n
    Switch Connection    R5
    Write    bridge default; allowed-vlan add ${limit_vlan} ; vlan ${limit_vlan}; mac limit maximum ${limit};
    Commit Testcase
    Write      exit;interface ${dut_iface2};mode access; access vlan ${limit_vlan};
    Write    mac limit maximum ${limit};
    Commit Testcase
    Switch Connection    DUT_shell
    Write    lua
    Read Until    Console#
    Write    show mac address-table count device all
    ${li}=    Read Until    Console#
    Append To File    path=${file_name}  content= Initial LUA Reading\n\n
    Append To File    path=${file_name}  content= ${li}\n\n
    FOR  ${i}   IN RANGE   1    130
        Switch Connection    R5
        Write    top
        Append To File    path=${file_name}  content=Iteration ${i}\n\n
        Write    top; bridge default; interface ${dut_iface2}
        # Sleep    ${sleep_duration}
        # Append To File    path=${file_name}  content= Cleared MAC and slept ${sleep_duration}\n

        Switch Connection     SERVER
        Write    sudo python3 ${scripts_base_dir}/send_serial_mac.py ${mac_to_be_sent} ${server_iface} ${mac_burst_size} 2
        ${cli}=     Read Until Prompt
        Should Contain     ${cli}     sent
        Sleep     ${sleep_dur_server}


        Switch Connection    DUT_shell
        Write    show mac address-table count device all
        ${li}=    Read Until    Console#
        Append To File    path=${file_name}  content= LUA\n\n
        Append To File    path=${file_name}  content= ${li}\n\n

        
        # Switch Connection    R5
        # Append To File    path=${file_name}  content= Sent ${limit_packetcount} random MAC\n
        # Write      do show system resource-table | include FDB
        # ${cli}=    Read Until Prompt    strip_prompt= ${True}
        # Append To File    path=${file_name}  content= ${cli}\n\n
        # ${value}=    Get Third Last Integer    ${cli}
        # ${is_equal}=    Evaluate    ${value} >= ${limit_packetcount}
        # Run Keyword And Continue On Failure    Should Be True    ${is_equal}
        # Run Keyword If    not ${is_equal}    Append To File    path=${file_name}  content= Condition failed: ${value} is less than ${limit_packetcount}\n

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
    Switch Connection    DUT_shell
    Write    CLIexit
    Read Until Prompt


*** Keywords ***
Cleanup
    Switch Connection     R5
    Write    bridge default; no interface ${dut_iface2};
    Commit Testcase