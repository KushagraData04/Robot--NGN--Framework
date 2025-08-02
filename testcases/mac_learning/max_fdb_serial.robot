*** Settings ***
Documentation       mac learning with access vlan in Falcon 118
Default Tags        Falcon 118
Library             SSHLibrary
Variables           data/max_fdb.yaml
Resource            resource/common.resource
Suite Teardown      Cleanup


*** Test Cases ***
Test to check mac aging in falcon 118
    Switch Connection     falcon118
    FOR    ${port}    IN    @{falcon_Ports}
        Write     interface physical ${port}; breakout to-four;
    END
    Commit Testcase
    Write    top;
    Read Until Prompt
    Write     interface physical ${phy};admin-status up;link-speed 100g;
    Commit Testcase
    Sleep    10s
    Write    top
    Write    bridge default;allowed-vlan add ${vlan} ; vlan ${vlan}; mac limit maximum ${fdb_limit}
    Commit Testcase
    Write    exit;interface ${dut_iface2};mode access; access vlan ${vlan}; mac limit maximum ${fdb_limit}
    Commit Testcase 
    Write    mac clear
    Write    top
    Write    l2 aging-time ${aging_time}
    Commit Testcase
    Switch Connection    156
    Write    sudo python3 krishna/send_serial_mac.py ${packetcount} ${server_iface} ${burst_size}  #for serial mac
    # Write    sudo python3 krishna/send_random.py ${packetcount} ${server_iface} ${burst_size} #for random mac

    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     sent
    Sleep    5s
    Switch Connection    falcon118
    Write     do show layer2 interface brief ${dut_iface2} dynamic-fdb
    ${cli}=    Read Until Prompt
    Should Contain    ${cli}    ${pack}

*** Keywords ***
Cleanup
    Switch Connection    falcon118
    Write    bridge default; no interface ${dut_iface2};
    Write    top; l2 aging-time 300
    Commit Testcase