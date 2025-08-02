*** Settings ***
Name                ERSPAN
Documentation       Check ERSPAN feature
Default Tags        Falcon 118
Library             SSHLibrary
Variables           data/l2_suite.yaml
Resource            resource/erspan.resource
Resource            resource/common.resource
Suite Teardown      Cleanup


*** Test Cases ***
Test to check erspan in falcon 118
    Switch Connection    DUT
    ${vlan_end}=     Evaluate    ${erspan_total_session} + ${erspan_start_vlan} + 2
    Write    top;bridge default;
    Write    allowed-vlan add ${erspan_start_vlan}-${vlan_end}
    Write    interface ${dut_iface1};mode trunk;trunk allowed vlan add ${erspan_start_vlan}-${vlan_end}
    # below for loop creates subif on bridge and assigns ip based on counter 
    # which is calculated used mirroring sessions and vlan range provided
    FOR  ${session}    IN RANGE   2    ${erspan_total_session} + 2
        ${counter}=     Evaluate    ${session} + ${erspan_start_vlan}
        Write    top;bridge default;
        Write    vlan ${counter}; irb enable;top;
        Write    interface subif bvi-1.${counter}; admin-status up;
        Write    ipv4 address ${counter}.${counter}.${counter}.1 prefix 24;
    END
    Commit Testcase
    
    Write    top
    FOR  ${session}    IN RANGE   2    ${erspan_total_session} + 2
        ${counter}=     Evaluate    ${session} + ${erspan_start_vlan}
        Write    mirroring session ${session} type erspan-source
        Write    mirror-destination ip ${counter}.${counter}.${counter}.10; admin-status up
        Write    origin ip ${erspan_origin_ip}
        Commit Testcase 
    END
    Write    top;access-lists ipv4 erspan
    FOR  ${session}    IN RANGE    2    ${erspan_total_session} + 2
        ${counter}=     Evaluate    ${session} + ${erspan_start_vlan}
        Write    1${session} permit ${session}.100.100.100 ${erspan_acl_mask} any mirror-session-id ${session}    
    END
    Write    30 permit any any
    Commit Testcase
    Write    top; interface physical ${dut_iface2_cli}
    Write    ipv4 access-group erspan ingress
    Write    interface-statistics
    Commit Testcase
    Write    top; do clear interface packet-statistics;
    Write    access-lists ipv4 erspan clear

    Switch Connection     SERVER
    FOR  ${session}    IN RANGE   2    ${erspan_total_session} + 2
        ${counter}=     Evaluate    ${session} + ${erspan_start_vlan}
        Sleep    1s
        Write    sudo ${scripts_base_dir}/phy_subif_create.sh ${counter} ${counter}.${counter}.${counter}.10/24 ${counter}.${counter}.${counter}.1 ${server_iface1}
        ${cli}=     Read Until Prompt
        Should Contain     ${cli}     sent
    END
    
    FOR  ${session}  IN RANGE    2    ${erspan_total_session} + 2
        Erspan send packet from server    ${session}
        Sleep    1s
    END
    Sleep    5s
    Switch Connection    DUT
    FOR  ${session}  IN RANGE    2    ${erspan_total_session} + 2
        Check acl counters for erspan    ${session}
    END

*** Keywords ***
Cleanup
    Switch Connection     DUT
    Write    top; interface physical ${dut_iface2_cli}
    Read Until Prompt
    Write    no ipv4 access-group erspan ingress
    Write    top; no access-lists ipv4 erspan
    Commit Testcase
    FOR  ${session}    IN RANGE    2    ${erspan_total_session} + 2
        Write    no mirroring session ${session}
    END
    Commit Testcase

