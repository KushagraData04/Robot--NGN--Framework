*** Settings ***
Documentation       Test Cases
Library             SSHLibrary
Library             pandas
Library             re
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             BuiltIn
#Library             helpers
Library             dataframes_utils.py
Variables           ../../data/mclag_falcon.yaml
Resource            ../../resource/mclag.resource

*** Test Cases ***
#############################
#lxc1_setup
#############################

Enter config mode
   Open Connection    ${DUT_IP1}    alias=${peer1.hostname}    prompt=${DUT_PROMPT1}      timeout=${DUT_TIMEOUT}     port=${peer1.ssh_port}
   Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
   Write    config; system cli prompt2 ${DUT_PROMPT1}; system cli notifications disable; commit; exit
   Read Until Prompt
   Write     config;
   Read Until Prompt
   Open Connection    ${DUT_IP2}    alias=${peer2.hostname}    prompt=${DUT_PROMPT2}      timeout=${DUT_TIMEOUT}     port=${peer2.ssh_port}
   Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
   Write    config; system cli prompt2 ${DUT_PROMPT2}; system cli notifications disable; commit; exit
   Read Until Prompt
   Write     config;
   Read Until Prompt
   Open Connection    ${DUT_IP3}    alias=${host1.hostname}    prompt=${DUT_PROMPT3}      timeout=${DUT_TIMEOUT}     port=${host1.ssh_port}
   Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
   Write    config; system cli prompt2 ${DUT_PROMPT3}; system cli notifications disable; commit; exit
   Read Until Prompt
   Write     config;
   Read Until Prompt
   Open Connection    ${DUT_IP4}    alias=${host2.hostname}    prompt=${DUT_PROMPT4}      timeout=${DUT_TIMEOUT}     port=${host2.ssh_port}
   Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
   Write    config; system cli prompt2 ${DUT_PROMPT4}; system cli notifications disable; commit; exit
   Read Until Prompt
   Write     config;
   Read Until Prompt   

Test Case Keep Alive ID lxc1
   Switch Connection    ${peer1.hostname}
   [Documentation]    Keep Alive ID
   Write    do show mclag index 1
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     OK

Test Case Keep Alive ID lxc2
   Switch Connection    ${peer2.hostname}
   [Documentation]    Keep Alive ID
   Write    do show mclag index 1
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     OK

Test Case State lxc1
   Switch Connection    ${peer1.hostname}
   [Documentation]    Bundle State Check
   Write    do show bundle interface bundle-1
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     current
    Write   do show bundle interface bundle-23
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     current
    Write   do show bundle interface bundle-45
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     current

Test Case State lxc2
   Switch Connection    ${peer2.hostname}
   [Documentation]    Bundle State Check
   Write    do show bundle interface bundle-1
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     current
   Write   do show bundle interface bundle-23
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     current
   Write   do show bundle interface bundle-45
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     current

Test Case Interface State lxc1
   Switch Connection    ${peer1.hostname}
   [Documentation]    Interface State Check
   Write    do show bundle interface
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     current

Test Case Interface State lxc2
   Switch Connection    ${peer2.hostname}
   [Documentation]    Interface State Check
   Write    do show bundle interface
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     current

Test Case Interface State lxc3
   Switch Connection    ${host1.hostname}
   [Documentation]    Interface State Check
   Write    do show bundle interface
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     current

Test Case Interface State lxc4
   Switch Connection    ${host2.hostname}
   [Documentation]    Interface State Check
   Write    do show bundle interface
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     current

Test Case LLDP lxc1
   Switch Connection    ${peer1.hostname}
   [Documentation]    LLDP Check
   Write    do show lldp neighbour
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     lxc2    lxc3    lxc4

Test Case LLDP lxc2
   Switch Connection    ${peer2.hostname}
   [Documentation]    LLDP Check
   Write    do show lldp neighbour
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     lxc1    lxc3    lxc4

Test Case LLDP lxc3
   Switch Connection    ${host1.hostname}
   [Documentation]    LLDP Check
   Write    do show lldp neighbour
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     lxc2

Test Case LLDP lxc4
   Switch Connection    ${host2.hostname}
   [Documentation]    LLDP Check
   Write    do show lldp neighbour
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     lxc2

Test Case Ping from Host1 to Host2 and Peer1(Peer2)
   Switch Connection    ${host1.hostname}
   [Documentation]    Ping Check
   Write    do ping 100.100.100.1 count 2
   Write    do ping 100.100.100.3 count 2
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     0% packet loss

Test Case Ping from Host2 to Host1 and Peer1(Peer2)
   Switch Connection    ${host2.hostname}
   [Documentation]    Ping Check
   Write    do ping 100.100.100.1 count 2
   Write    do ping 100.100.100.2 count 2
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     0% packet loss

Test Case Port Isolation Peer1
   Switch Connection    ${peer1.hostname}
   [Documentation]    Check the bundles are same or not
   Write    do show port-isolation
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     bundle-23    bundle-45

Test Case Port Isolation Peer2
   Switch Connection    ${peer2.hostname}
   [Documentation]    Check the bundles are same or not
   Write    do show port-isolation
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     bundle-23    bundle-45

Test Case Peer1 Role
   Switch Connection    ${peer1.hostname}
   [Documentation]    Role Check
   Write    do show mclag index 1
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     Role: Active    MCLAG Interface: bundle-45,bundle-23

Test Case Peer2 Role
   Switch Connection    ${peer2.hostname}
   [Documentation]    Role Check
   Write    do show mclag index 1
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     Role: Standby    MCLAG Interface: bundle-45,bundle-23

Compare MCLAG MAC Entries
    Switch Connection    ${peer1.hostname}
    ${data_lxc1}=     Run Command    show mclag index 1 mac

    Switch Connection    ${peer2.hostname}
    ${data_lxc2}=     Run Command    show mclag index 1 mac
    
    ${fdb_entries_lxc1}=    parse_fdb_entries    """${data_lxc1}"""
    ${fdb_entries_lxc2}=    parse_fdb_entries    """${data_lxc2}"""

    Log To Console    mac1:${fdb_entries_lxc1}
    Log To Console    mac2:${fdb_entries_lxc2}
   
    ${result}=    compare_fdb_entries    ${fdb_entries_lxc1}    ${fdb_entries_lxc2}
    Should Contain      ${result}   PASS

Compare MCLAG ARP Entries
    Switch Connection    ${peer1.hostname}
    ${df_lxc1}=     Write    show mclag index 1 arp

    Switch Connection    ${peer2.hostname}
    ${df_lxc2}=     Write    show mclag index 1 arp
    
    ${arp_entries_lxc1}=    parse_arp_entries    """${df_lxc1}"""
    ${arp_entries_lxc2}=    parse_arp_entries    """${df_lxc2}"""

    Log To Console    arp1:${arp_entries_lxc1}
    Log To Console    arp2:${arp_entries_lxc2}
   
    ${result1}=    compare_arp_entries    ${arp_entries_lxc1}    ${arp_entries_lxc2}
    Should Contain      ${result1}   PASS

Compare MCLAG Interfaces
    Switch Connection    ${peer1.hostname}
    ${df_lxc1}=     Run Command    show mclag index 1 details

    Switch Connection    ${peer2.hostname}
    ${df_lxc2}=     Run Command    show mclag index 1 details
    
    Log To Console    ${df_lxc1}
    Log To Console    ${df_lxc2}

    ${peer_link_mac}=   Get MAC Address    ${df_lxc1}    Peer Link Mac:
    ${bundle_45_mac}=   Get MAC Address    ${df_lxc1}    MAC:
    ${bundle_23_mac}=   Get MAC Address    ${df_lxc1}    MAC:

    #${peer_link_mac2}=   Get MAC Address    ${df_lxc2}    Peer Link Mac:
    ${bundle_45_mac2}=   Get MAC Address    ${df_lxc2}    MAC:
    ${bundle_23_mac2}=   Get MAC Address    ${df_lxc2}    MAC:

    Log To Console    ${peer_link_mac}
    Log To Console    ${bundle_45_mac}
    Log To Console    ${bundle_23_mac}
    #Log To Console    ${peer_link_mac2}
    Log To Console    ${bundle_45_mac2}
    Log To Console    ${bundle_23_mac2}
    
    Should Be Equal    ${peer_link_mac}    ${bundle_45_mac}
    Should Be Equal    ${peer_link_mac}    ${bundle_23_mac}

    Should Be Equal    ${peer_link_mac}    ${bundle_45_mac2}
    Should Be Equal    ${peer_link_mac}    ${bundle_23_mac2} 

Compare the MCLAG APR Entries after bundle is down for Peer1 & Peer2
    Switch Connection    ${peer1.hostname}
    Write    interface bundle 23 ; admin-status down ; commit
    ${df_lxc1}=     Run Command    show mclag index 1 arp
    
    Switch Connection    ${peer2.hostname}
    Write    interface bundle 45 ; admin-status down ; commit
    ${df_lxc2}=     Run Command    show mclag index 1 arp
    
    ${arp_entries_lxc1}=    parse_arp_entries    """${df_lxc1}"""
    ${arp_entries_lxc2}=    parse_arp_entries    """${df_lxc2}"""

    Log To Console    arp1:${arp_entries_lxc1}
    Log To Console    arp2:${arp_entries_lxc2}
   
    ${result1}=    compare_arp_entries    ${arp_entries_lxc1}    ${arp_entries_lxc2}
    Should Contain      ${result1}   PASS

Compare the MCLAG ND Entries after bundle is down for Peer1 & Peer2
    Switch Connection    ${peer1.hostname}
    ${df_lxc1_nd}=     Run Command    show mclag index 1 nd
    
    Switch Connection    ${peer2.hostname}
    ${df_lxc2_nd}=     Run Command    show mclag index 1 nd
    
    ${nd_entries_lxc1}=    parse_nd_entries    """${df_lxc1_nd}"""
    ${nd_entries_lxc2}=    parse_nd_entries    """${df_lxc2_nd}"""

    Log To Console    nd1:${nd_entries_lxc1}
    Log To Console    nd2:${nd_entries_lxc2}
   
    ${result1}=    compare_nd_entries    ${nd_entries_lxc1}    ${nd_entries_lxc2}
    Should Contain      ${result1}   PASS
   
Ping test after bundle is down
   Switch Connection    ${host1.hostname}
   [Documentation]    Ping Check
   Write    do ping 100.100.100.3 count 10
   Write    do ping 100.100.100.1 count 10
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     0% packet loss

   Switch Connection    ${host2.hostname}
   Write    do ping 100.100.100.2 count 10
   Write    do ping 100.100.100.1 count 10
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     0% packet loss

Bringing the status of bundles up again for Peer1 & Peer2
    Switch Connection    ${peer1.hostname}
    Write    interface bundle 23 ; admin-status up ; commit
    
    Switch Connection    ${peer2.hostname}
    Write    interface bundle 45 ; admin-status up ; commit

Compare the MCLAG APR Entries after interface is down for Peer1 & Peer2
    Switch Connection    ${peer1.hostname}
    Write    interface physical 1/1/1 ; admin-status down ; commit
    ${df_lxc1}=     Run Command    show mclag index 1 arp
    
    Switch Connection    ${peer2.hostname}
    Write    interface physical 1/1/1 ; admin-status down ; commit
    ${df_lxc2}=     Run Command    show mclag index 1 arp
    
    ${arp_entries_lxc1}=    parse_arp_entries    """${df_lxc1}"""
    ${arp_entries_lxc2}=    parse_arp_entries    """${df_lxc2}"""

    Log To Console    arp1:${arp_entries_lxc1}
    Log To Console    arp2:${arp_entries_lxc2}
   
    ${result1}=    compare_arp_entries    ${arp_entries_lxc1}    ${arp_entries_lxc2}
    Should Contain      ${result1}   PASS

Compare the MCLAG ND Entries after interface is down for Peer1 & Peer2
    Switch Connection    ${peer1.hostname}
    ${df_lxc1_nd}=     Run Command    show mclag index 1 nd
    
    Switch Connection    ${peer2.hostname}
    ${df_lxc2_nd}=     Run Command    show mclag index 1 nd
    
    ${nd_entries_lxc1}=    parse_nd_entries    """${df_lxc1_nd}"""
    ${nd_entries_lxc2}=    parse_nd_entries    """${df_lxc2_nd}"""

    Log To Console    nd1:${nd_entries_lxc1}
    Log To Console    nd2:${nd_entries_lxc2}
   
    ${result1}=    compare_nd_entries    ${nd_entries_lxc1}    ${nd_entries_lxc2}
    Should Contain      ${result1}   PASS

Ping test after interface is down
   Switch Connection    ${host1.hostname}
   [Documentation]    Ping Check
   Write    do ping 100.100.100.3 count 10
   Write    do ping 100.100.100.1 count 10
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     0% packet loss

   Switch Connection    ${host2.hostname}
   Write    do ping 100.100.100.2 count 10
   Write    do ping 100.100.100.1 count 10
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     0% packet loss

Bringing the status of interfaces up again for Peer1 & Peer2
    Switch Connection    ${peer1.hostname}
    Write    interface physical 1/1/1 ; admin-status up ; commit
    
    Switch Connection    ${peer2.hostname}
    Write    interface physical 1/1/1 ; admin-status up ; commit

Compare the MCLAG APR Entries after interface is down for Peer1 & Peer2
    Switch Connection    ${peer1.hostname}
    Write    interface physical 1/6/1 ; admin-status down ; commit
    ${df_lxc1}=     Run Command    show mclag index 1 arp
    
    Switch Connection    ${peer2.hostname}
    Write    interface physical 1/6/1 ; admin-status down ; commit
    ${df_lxc2}=     Run Command    show mclag index 1 arp
    
    ${arp_entries_lxc1}=    parse_arp_entries    """${df_lxc1}"""
    ${arp_entries_lxc2}=    parse_arp_entries    """${df_lxc2}"""

    Log To Console    arp1:${arp_entries_lxc1}
    Log To Console    arp2:${arp_entries_lxc2}
   
    ${result1}=    compare_arp_entries    ${arp_entries_lxc1}    ${arp_entries_lxc2}
    Should Contain      ${result1}   PASS

Compare the MCLAG ND Entries after interface is down for Peer1 & Peer2
    Switch Connection    ${peer1.hostname}
    ${df_lxc1_nd}=     Run Command    show mclag index 1 nd
    
    Switch Connection    ${peer2.hostname}
    ${df_lxc2_nd}=     Run Command    show mclag index 1 nd
    
    ${nd_entries_lxc1}=    parse_nd_entries    """${df_lxc1_nd}"""
    ${nd_entries_lxc2}=    parse_nd_entries    """${df_lxc2_nd}"""

    Log To Console    nd1:${nd_entries_lxc1}
    Log To Console    nd2:${nd_entries_lxc2}
   
    ${result1}=    compare_nd_entries    ${nd_entries_lxc1}    ${nd_entries_lxc2}
    Should Contain      ${result1}   PASS
    
Ping test after interface is down
   Switch Connection    ${host1.hostname}
   [Documentation]    Ping Check
   Write    do ping 100.100.100.3 count 10
   Write    do ping 100.100.100.1 count 10
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     0% packet loss

   Switch Connection    ${host2.hostname}
   Write    do ping 100.100.100.2 count 10
   Write    do ping 100.100.100.1 count 10
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     0% packet loss

Bringing the status of interfaces up again for Peer1 & Peer2
    Switch Connection    ${peer1.hostname}
    Write    interface physical 1/6/1 ; admin-status up ; commit
    
    Switch Connection    ${peer2.hostname}
    Write    interface physical 1/6/1 ; admin-status up ; commit

Ping test loopback IP
   Switch Connection    ${host1.hostname}
   [Documentation]    Ping Check
   Write    do ping 2.2.2.3 count 10
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     0% packet loss

   Switch Connection    ${host2.hostname}
   Write    do ping 2.2.2.3 count 10
   ${cli}=    Read Until Prompt
   Should Contain    ${cli}     0% packet loss

# Ping test loopback IP if interface is down for Peer1 & Peer2
#     Switch Connection    ${peer1.hostname}
#     Write    interface physical 1/6/1 ; admin-status down ; commit
    
#     Switch Connection    ${peer2.hostname}
#     Write    interface physical 1/6/1 ; admin-status down ; commit