*** Settings ***
Name                Intervlan routing
Documentation       Test intervlan routings between given number of vlans
Default Tags        Falcon 118
Library             SSHLibrary
Library             OperatingSystem
Variables           data/l2_suite.yaml
Resource            resource/erspan.resource
Resource            resource/common.resource
Suite Teardown      Cleanup


*** Test Cases ***
Simulate multiple neighbors via server
    Switch Connection     R5

    Write    top; bridge default;
    Write    allowed-vlan add ${intervlan_vlan_start}-${intervlan_vlan_end}
    Write    interface ${dut_iface2}; mode trunk; trunk allowed vlan add ${intervlan_vlan_start}-${intervlan_vlan_end};
    Commit Testcase

    Write    top; bridge default;
    FOR  ${session}    IN RANGE   1    ${intervlan_total_vlan} + 1   
        ${vlan}=    Evaluate    ${intervlan_vlan_start} + ${session}
        Write    vlan ${vlan}; irb enable;
    END
    Commit Testcase
    
    Write    top
    FOR  ${session}    IN RANGE   1    ${intervlan_total_vlan} + 1   
        ${vlan}=    Evaluate    ${intervlan_vlan_start} + ${session}
        Write    interface subif bvi-1.${vlan}; admin-status up;
        Write    ipv4 address 25.40.${session}.1 prefix ${intervlan_prefix}
    END
    Commit Testcase

    Switch Connection    SERVER
    FOR  ${session}    IN RANGE   1    ${intervlan_total_vlan} + 1
        ${vlan}=    Evaluate    ${intervlan_vlan_start} + ${session}
        # create multiple subifs at the server end based on i/p i.e VLAN      IP/Prefix    gateway ip     server_interface 
        Write    sudo ${scripts_base_dir}/script/irb_create.sh ${vlan} 25.40.${session}.2 25.40.${session}.1 ${server_iface}
        ${cli}=     Read Until Prompt
    END
    FOR  ${session}    IN RANGE   1    ${intervlan_total_vlan} + 1
        FOR  ${counter}  IN RANGE    1    ${intervlan_total_vlan} + 1
            ${vlan}=    Evaluate    ${intervlan_vlan_start} + ${session}
            Run Keyword If    '${counter}' != '${session}'    Execute Ping Command    ${session}    ${counter}    ${vlan}
        END
    END


*** Keywords ***
Execute Ping Command
    [Arguments]    ${session}    ${counter}    ${vlan}
    Write    sudo ${scripts_base_dir}/script/irb_ping.sh ${vlan} 25.40.${counter}.2 
    ${cli}=     Read Until Prompt

Cleanup
    Switch Connection    R5
    Write    top;bridge default; no interface ${dut_iface2};
    FOR  ${session}    IN RANGE   1    ${intervlan_total_vlan} + 1   
        ${vlan}=    Evaluate    ${intervlan_vlan_start} + ${session}
        Write    no vlan ${vlan}
    END
    Commit Testcase
    Switch Connection    SERVER
    FOR  ${session}    IN RANGE   1    ${intervlan_total_vlan} + 1
        ${vlan}=    Evaluate    ${intervlan_vlan_start} + ${session}
        Write    sudo ${scripts_base_dir}/script/irb_delete.sh ${vlan}
        Read Until Prompt
    END
    Sleep    5s