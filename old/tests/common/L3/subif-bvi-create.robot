*** Settings ***
Documentation       Test case to whitelist subnet for login
Default Tags        whitelist all
Library             SSHLibrary
Resource            ../resource/common1.resource
Variables           ../data/subif-bvi-create.yaml
Variables           ../data/credentials.yaml
Suite Teardown      Close All Connections

*** Variables ***
${counter}    0
${bundle_counter}    0
${bvi_counter}    0

*** Test Cases ***
Open all connections
    # Open Connection    192.168.111.117    alias=stbr117      prompt=STBR-117#      timeout=600s
    # Login    ${USERNAME}    Root@357
    # Open Connection    192.168.111.130    alias=stbr130      prompt=STBR-130#      timeout=600s
    # Login    ${USERNAME}    ${PASSWORD}
    Open Connection    192.168.111.118    alias=falcon118    prompt=CTX-3000-v01-111-118#      timeout=600s
    Login    ${USERNAME}    ${PASSWORD}

# Enter config mode stbr
#     Switch Connection     stbr117
#     Write and wait    config; system cli prompt2 STBR-117#;system cli notifications disable; commit; exit
#     Write and wait    config;

# Enter config mode stbr 130
#     Switch Connection     stbr130
#     Write and wait    config; system cli prompt2 STBR-130#;system cli notifications disable; commit; exit
#     Write and wait    config;

Enter config mode falcon
    Switch Connection     falcon118
    Write and wait    config; system cli prompt2 CTX-3000-v01-111-118#;system cli notifications disable; commit; exit
    Write and wait    config;

# Interface configuration stbr
#     Switch Connection     stbr117
#     [Documentation]     Admin up interfaces
#     FOR    ${port}    IN    @{stbr_Ports}
#         Write     interface physical ${port};admin-status up;
#         Write     lldp transmit
#         Write     lldp receive
#         Read Until Prompt
#     END 
#     Commit Testcase
#     Write     interface bundle 47
#     Write     mode 802.3ad;lacp rate fast; admin-status up;
#     FOR    ${port}    IN    @{stbr_bundle_ports}
#         ${cli}=    Write    port ${port}
#         Read Until Prompt 
#     END
#     Commit Testcase
#     Write    bridge default; allowed-vlan 2-250;
#     Write    interface bundle-47; mode trunk; trunk allowed vlan add 2-250
#     Commit Testcase

# Interface configuration stbr 130
#     Switch Connection     stbr130
#     [Documentation]     Admin up interfaces
#     FOR    ${port}    IN    @{stbr130_Ports}
#         Write     interface physical ${port};admin-status up;
#         Write     lldp transmit
#         Write     lldp receive
#         Read Until Prompt
#     END
#     Commit Testcase
#     Write    bridge default; allowed-vlan 2-250;
#     FOR    ${port}    IN    @{stbr130_bundle_ports}
#         Write    interface ${port}; mode trunk; trunk allowed vlan add 2-250
#     END
#     Commit Testcase

Interface configuration falcon
    Switch Connection     falcon118
    [Documentation]     Admin up interfaces
    FOR    ${port}    IN    @{falcon_Ports}
        Write     interface physical ${port};admin-status up;
        Write     breakout to-four
        Write     lldp transmit
        Write     lldp receive
        Read Until Prompt
    END 
    Commit Testcase
    Write    top;
    Read Until Prompt
    Write     interface physical ${phy};admin-status up;link-speed 10g;
    Commit Testcase

Create bundle on falcon
    Switch Connection     falcon118
    [Documentation]    Create bundle of all members
    Write     interface bundle ${bundle_id}
    Write     mode 802.3ad;lacp rate fast; admin-status up;
    FOR    ${port}    IN    @{falcon_bundle_ports}
        Write    port ${port}
        Read Until Prompt
    END
    Commit Testcase

Falcon Create subif on bundle
    Switch Connection     falcon118
    [Documentation]    Create subif on bundle
    FOR    ${port}    IN RANGE    1   ${subif_count} + 1
        ${counter} =    Evaluate    ${counter} + 1
        ${acl_name} =    Evaluate    ${bundle_counter} + ${port}
        Write    interface subif bundle-${bundle_id}.${port}
        Write    admin-status up
        Write    ipv4 access-group ${bundle_acl_prefix}${acl_name} ingress
        Write    interface-statistics
        Write    ipv4 address 1.${bundle_subif_2nd_octet}.${port}.1 prefix 24
        Read Until Prompt
        Run Keyword If    ${counter} % 10 == 0    Sleep     ${sleep_val}
    END
    Commit Testcase
    Set Global Variable    ${counter}    0

Falcon Create subif on physical
    Switch Connection     falcon118
    [Documentation]    Create subif on physical
    FOR    ${port}    IN RANGE    1   ${subif_count} + 1
        ${counter} =    Evaluate    ${counter} + 1
        Write    interface subif ${phy_for_subif}.${port}
        Write    admin-status up
        Write    ipv4 access-group ${subif_acl_prefix}${port} ingress
        Write    interface-statistics
        Write    ipv4 address 1.${phy_subif_2nd_octet}.${port}.1 prefix 24
        Read Until Prompt
        Run Keyword If    ${counter} % 10 == 0    Sleep     ${sleep_val}
    END
    Commit Testcase
    Set Global Variable    ${counter}    0

Falcon Create bvi
    Switch Connection     falcon118
    [Documentation]    Create bvi
    Write               bridge default
    Write               allowed-vlan add 1-250
    FOR    ${port}    IN RANGE    1   ${subif_count} + 1
        ${counter} =    Evaluate    ${counter} + 1

        Write    vlan ${port}
        Write    irb enable
        Read Until Prompt
        Run Keyword If    ${counter} % 10 == 0    Commit Testcase
        Run Keyword If    ${counter} % 10 == 0    Sleep     ${sleep_val}
    END
    Commit Testcase
    Set Global Variable    ${counter}    0

    FOR    ${port}    IN RANGE    1   ${subif_count} + 1
        ${counter} =    Evaluate    ${counter} + 1
        ${acl_name} =    Evaluate    ${bvi_counter} + ${port}
        Write    interface subif bvi-1.${port}
        Write    admin-status up
        Write    ipv4 access-group ${bvi_acl_prefix}${acl_name} ingress
        Write    interface-statistics
        Write    ipv4 address 1.${bvi_2nd_octet}.${port}.1 prefix 24
        Read Until Prompt
        Run Keyword If    ${counter} % 10 == 0    Commit Testcase
        Run Keyword If    ${counter} % 10 == 0    Sleep     ${sleep_val}
    END
    Commit Testcase
    Set Global Variable    ${counter}    0

# Cleanup stbr
#     Switch Connection     stbr117
#     [Documentation]     Cleanup
#     Write               bridge default
#     Write               no interface bundle-47
#     Commit Testcase
#     Write     no interface bundle 47
#     Commit Testcase

# Cleanup stbr 130
#     Switch Connection     stbr130
#     [Documentation]     Cleanup
#     Write               bridge default
#     FOR    ${port}    IN    @{stbr130_bundle_ports}
#         Write    no interface ${port};
#     END
#     Commit Testcase

Cleanup falcon
    Skip
    Switch Connection     falcon118
    [Documentation]     Cleanup
    FOR    ${port}    IN RANGE    1   ${subif_count} + 1
        Write    no interface subif bundle-${bundle_id}.${port}
        Read Until Prompt
    END
    Commit Testcase

    FOR    ${port}    IN RANGE    1   ${subif_count} + 1
        Write    no interface subif ${phy_for_subif}.${port}
        Read Until Prompt
    END
    Commit Testcase

    Write               bridge default
    FOR    ${port}    IN RANGE    1   ${subif_count} + 1
        Write    no vlan ${port}
        Read Until Prompt
    END
    Commit Testcase

    Write     no interface bundle ${bundle_id}
    Commit Testcase