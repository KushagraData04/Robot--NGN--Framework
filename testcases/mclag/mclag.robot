*** Settings ***
Documentation       Configuration for lxc
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Variables           ../../data/mclag_generic.yaml
Resource            ../../resource/common.resource


*** Test Cases ***
#############################
#lxc1_setup
#############################

Enter config mode
   Open Connection    ${DUT_IP}    alias=${peer1.hostname}    prompt=${DUT_PROMPT1}      timeout=${DUT_TIMEOUT}     port=${peer1.ssh_port}
   Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
   Write    config; system cli prompt2 ${DUT_PROMPT1}; system cli notifications disable; commit; exit
   Read Until Prompt
   Write     config;
   Read Until Prompt
   Open Connection    ${DUT_IP}    alias=${peer2.hostname}    prompt=${DUT_PROMPT2}      timeout=${DUT_TIMEOUT}     port=${peer2.ssh_port}
   Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
   Write    config; system cli prompt2 ${DUT_PROMPT2}; system cli notifications disable; commit; exit
   Read Until Prompt
   Write     config;
   Read Until Prompt
   Open Connection    ${DUT_IP}    alias=${host1.hostname}    prompt=${DUT_PROMPT3}      timeout=${DUT_TIMEOUT}     port=${host1.ssh_port}
   Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
   Write    config; system cli prompt2 ${DUT_PROMPT3}; system cli notifications disable; commit; exit
   Read Until Prompt
   Write     config;
   Read Until Prompt
   Open Connection    ${DUT_IP}    alias=${host2.hostname}    prompt=${DUT_PROMPT4}      timeout=${DUT_TIMEOUT}     port=${host2.ssh_port}
   Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
   Write    config; system cli prompt2 ${DUT_PROMPT4}; system cli notifications disable; commit; exit
   Read Until Prompt
   Write     config;
   Read Until Prompt
   Open Connection    ${DUT_IP}    alias=${hostpa.hostname}   prompt=${DUT_PROMPT5}      timeout=${DUT_TIMEOUT}     port=${hostpa.ssh_port}
   Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
   Write    config; system cli prompt2 ${DUT_PROMPT5}; system cli notifications disable; commit; exit
   Read Until Prompt
   Write     config;
   Read Until Prompt   

Initial configuration
   [Documentation]     Admin up interfaces ${peer1.hostname}
   Switch Connection    ${peer1.hostname}

   # Loop through each port and allocate them
   FOR    ${port_num}    IN    @{peer1.ports}
   Write     interface physical ${port_num.number}; admin-status up; link-speed ${port_num.linkspeed}; commit
   Read Until Prompt
   END
   Commit Testcase

Create Bundles and VLANs
   [Documentation]     Configure bundles and VLANs
   Enter Config Mode
   Read Until Prompt
   
   # Add VLANs to the allowed VLAN range before configuring bundles
   FOR    ${num}    IN    @{peer1.bundles}
   Write    bridge default; allowed-vlan add ${num.number}
   Commit Testcase
   END

   # Loop through each bundle and configure it with ports and mode
   FOR    ${bundle}    IN    @{peer1.bundles}
   ${cli}=    Write    interface bundle ${bundle.number}
   FOR    ${port}    IN    @{bundle.port}
   ${cli}=    Write    port ${port}
   END
   ${cli}=    Write    mode ${bundle.mode}; lacp rate ${bundle.lacp_rate}; admin-status up
   Commit Testcase
   END

Configure VLANs and Bridge
   [Documentation]    Configure bridge and VLANs
   ${cli}=             Write    top;

   # Loop through each bundle and configuring them with the values and allowed VLANs
   FOR    ${vlan}    IN    @{peer1.bundles}
   ${cli}=             Write    bridge default; allowed-vlan add 23,45,${vlan.allowed_vlan}; vlan 1000; irb enable
   END
   ${cli}=             Write    vlan 23; vlan 45
   Commit Testcase

Make bundle part of the bridge
   [Documentation]     Configure bundles in the bridge
   Write     top;
   Write    bridge default; allowed-vlan 1-1000;
   Commit Testcase

   # Loop 
   FOR    ${port}    IN RANGE    1    ${counter}
   Write    interface bundle-${port}; mode trunk;
   Read Until Prompt
   END
   Commit Testcase
   
Trunk Configuration
   [Documentation]    Configure trunk for bundles

   # Loop through each bundle to get configured with VLANs
   FOR    ${bundle}    IN    @{peer1.bundles}
   ${cli}=    Write    bridge default; interface bundle-${bundle.number} mode trunk
   ${cli}=    Write    trunk allowed vlan add ${bundle.allowed_vlan}
   ${cli}=    Write    trunk native vlan ${bundle.native_vlan}
   END
   Commit Testcase

# Configure IP Address for Interface
#    [Documentation]    Set IP address for physical interface
#    Write     top;
#    ${cli}=    Write    ${mclag_interface}

#    # Loop for bundle present in peer
#    FOR    ${bundle}    IN    @{peer1}
#    ${cli}=    Write    ipv4 address ${peer1.iccp_ip} prefix 24
#    END
#    Commit Testcase

MC-LAG Configuration
  [Documentation]    Configure MC-LAG for lxc1
  ${cli}=             Write    do autowizard false

  # Assignment of local and peer IPs
  FOR    ${bundle}    IN    @{peer1}
  ${cli}=             Write    ${mclag_instance}; local-ip ${peer1.iccp_ip}; peer-ip ${peer2.iccp_ip}; peer-link ${peer_link}
  END
  Commit Testcase
  ${cli}=             Write    interface bundle 23; ${mclag_instance}
  ${cli}=             Write    interface bundle 45; ${mclag_instance}
  FOR    ${bvi}    IN    @{peer1.bvis}
  ${cli}=             Write    interface subif ${bvi.name}; admin-status up; ipv4 address ${bvi.ip} prefix ${bvi.prefix}
  END
  Commit Testcase
  ${cli}=             Write    ${mclag_instance}; lacp-system-id ${lacp_system_id}
  Commit Testcase

Configure Loopback Interface
    [Documentation]   Configures loopback with IP
    Write   top;
    FOR    ${lb}    IN    @{peer1.loopback}
    ${cli}=    Write    interface loopback 1; admin-status up; ipv4 address ${lb.ip} prefix ${lb.prefix}; commit
    END
    Commit Testcase

Configure to Spine
  [Documentation]   Configures the bundle to spine
    Write   top;
    FOR    ${bs}    IN    @{peer1.bundles_to_spine1}
    ${cli}=    Write    interface bundle ${bs.number}
    #FOR    ${pt}    IN    @{bundles_to_spine.port}
    ${cli}=    Write    port ${bs.port}
    #END
    ${cli}=    Write    mode ${bs.mode}; lacp rate ${bs.lacp_rate}; admin-status up
    END
    FOR    ${bs}    IN    @{peer1.bundles_to_spine1}
    ${cli}=             Write    interface bundle ${bs.number}; admin-status up; ipv4 address ${bs.ip} prefix ${bs.prefix}
    END
    Commit Testcase
    
Configurations for OSPF
  [Documentation]   Configures the ospf
    Write   top;
    Write   do autowizard false;
    ${ospf}=    Get From Dictionary    ${peer1}    ospf
    ${process_id}=    Get From Dictionary    ${ospf}    process_id
    FOR  ${ip}  IN  @{peer1.loopback}
    Write   router ospf ${process_id} ; router-id ${ip.ip} ; redistribute connected ; exit
    END
    Write   area 0
    FOR    ${ip}    IN    @{peer1['ospf']['active_network']}
    Write    network ${ip} ; authentication none
    END
    FOR   ${ip}   IN   @{peer1.ospf.passive_network}
    Write   network ${ip} ; authentication none ; passive
    END
    Commit Testcase

Configuration of interface to bvi
  [Documentation]   Configures interface to bvi
    Write   top;
    Write   bridge default; allowed-vlan add 60; vlan 60; irb enable 
    Commit Testcase
    Write   top
    Write   interface subif bvi-1.60; ipv4 address 60.60.60.1 prefix 24 
    Commit Testcase
    Write   top
    Write   bridge default interface bundle-1 trunk allowed vlan add 60
    Commit Testcase
    Write   top
    write   interface subif bvi-1.60; admin-status up
    Commit Testcase
    Write  do copy r s
    Commit Testcase

# Configure Access Lists
#    [Documentation]    Configure access lists for ping isolation
#    ${cli}=             Write    access-lists ipv4 port_isolation_ping
#    ${cli}=             Write    10 permit icmp host ${ipv4_2} host ${ipv4_3}
#    ${cli}=             Write    20 permit icmp host ${ipv4_3} host ${ipv4_2}
#    ${cli}=             Write    65535 permit ip any any


#############################
#lxc2_setup
#############################

Initial configuration
   [Documentation]     Admin up interfaces ${peer2.hostname}
   Switch Connection    ${peer2.hostname}
   FOR    ${port_num}    IN    @{peer2.ports}
   Write     interface physical ${port_num.number}; admin-status up; link-speed ${port_num.linkspeed}; commit
   Read Until Prompt
   END
   Commit Testcase

Create Bundles and VLANs
   [Documentation]     Configure bundles and VLANs
   Enter Config Mode
   Read Until Prompt
   
   FOR    ${num}    IN    @{peer2.bundles}
   Write    bridge default; allowed-vlan add ${num.number}
   Commit Testcase
   END

   FOR    ${bundle}    IN    @{peer2.bundles}
   ${cli}=    Write    interface bundle ${bundle.number}
   FOR    ${port}    IN    @{bundle.port}
   ${cli}=    Write    port ${port}
   END
   ${cli}=    Write    mode ${bundle.mode}; lacp rate ${bundle.lacp_rate}; admin-status up
   Commit Testcase
   END

Configure VLANs and Bridge
   [Documentation]    Configure bridge and VLANs
   ${cli}=             Write    top;
   FOR    ${vlan}    IN    @{peer2.bundles}
   ${cli}=             Write    bridge default; allowed-vlan add 23,45,${vlan.allowed_vlan}; vlan 1000; irb enable;
   END
   ${cli}=             Write    vlan 23; vlan 45
   Commit Testcase

Make bundle part of the bridge
   [Documentation]     Configure bundles in the bridge
   Write     top;
   Write    bridge default; allowed-vlan 1-1000;
   Commit Testcase
   FOR    ${port}    IN RANGE    1    ${counter}
   Write    interface bundle-${port};mode trunk;
   Read Until Prompt
   END
   Commit Testcase
   
Trunk Configuration
   [Documentation]    Configure trunk for bundles
   FOR    ${bundle}    IN    @{peer2.bundles}
   ${cli}=    Write    bridge default; interface bundle-${bundle.number} mode trunk
   ${cli}=    Write    trunk allowed vlan add ${bundle.allowed_vlan}
   ${cli}=    Write    trunk native vlan ${bundle.native_vlan}
   END
   Commit Testcase

# Configure IP Address for Interface
#    [Documentation]    Set IP address for physical interface
#    Write     top;
#    ${cli}=    Write    ${mclag_interface}
#    FOR    ${bundle}    IN    @{peer2}
#    ${cli}=    Write    ipv4 address ${peer2.iccp_ip} prefix 24
#    END
#    Commit Testcase

MC-LAG Configuration
  [Documentation]    Configure MC-LAG for lxc2
  ${cli}=             Write    do autowizard false
  FOR    ${bundle}    IN    @{peer2}
  ${cli}=             Write    ${mclag_instance}; local-ip ${peer2.iccp_ip}; peer-ip ${peer1.iccp_ip}; peer-link ${peer_link}
  END
  Commit Testcase
  ${cli}=             Write    interface bundle 23; ${mclag_instance}
  ${cli}=             Write    interface bundle 45; ${mclag_instance}
  
  FOR    ${bvi}    IN    @{peer2.bvis}
  ${cli}=             Write    interface subif ${bvi.name}; admin-status up; ipv4 address ${bvi.ip} prefix ${bvi.prefix}
  END
  Commit Testcase
  ${cli}=             Write    ${mclag_instance}; lacp-system-id ${lacp_system_id}
  Commit Testcase

Configure Loopback Interface
    [Documentation]   Configures loopback with IP
    Write   top;
    FOR    ${lb}    IN    @{peer2.loopback}
    ${cli}=    Write    interface loopback 1; admin-status up; ipv4 address ${lb.ip} prefix ${lb.prefix}; commit
    END
    Commit Testcase

Configure to Spine
  [Documentation]   Configures the bundle to spine
    Write   top;
    FOR    ${bs}    IN    @{peer2.bundles_to_spine2}
    ${cli}=    Write    interface bundle ${bs.number}
    #FOR    ${pt}    IN    @{bundles_to_spine.port}
    ${cli}=    Write    port ${bs.port}
    #END
    ${cli}=    Write    mode ${bs.mode}; lacp rate ${bs.lacp_rate}; admin-status up
    END
    FOR    ${bs}    IN    @{peer2.bundles_to_spine2}
    ${cli}=             Write    interface bundle ${bs.number}; admin-status up; ipv4 address ${bs.ip} prefix ${bs.prefix}
    END
    Commit Testcase

Configurations for OSPF
  [Documentation]   Configures the ospf
    Write   top;
    Write   do autowizard false;
    ${ospf}=    Get From Dictionary    ${peer2}    ospf
    ${process_id}=    Get From Dictionary    ${ospf}    process_id
    FOR  ${ip}  IN  @{peer2.loopback}
    Write   router ospf ${process_id} ; router-id ${ip.ip} ; redistribute connected ; exit
    END
    Write   area 0
    FOR    ${ip}    IN    @{peer2['ospf']['active_network']}
    Write    network ${ip} ; authentication none
    END
    FOR   ${ip}   IN   @{peer2.ospf.passive_network}
    Write   network ${ip} ; authentication none ; passive
    END
    Commit Testcase

Configuration of interface to bvi
  [Documentation]   Configures interface to bvi
    Write   top;
    Write   bridge default; allowed-vlan add 60; vlan 60; irb enable 
    Commit Testcase
    Write   top
    Write   interface subif bvi-1.60; ipv4 address 60.60.60.2 prefix 24 
    Commit Testcase
    Write   top
    Write   bridge default interface bundle-1 trunk allowed vlan add 60
    Commit Testcase
    Write   top
    write   interface subif bvi-1.60; admin-status up
    Commit Testcase
    Write  do copy r s
    Commit Testcase

# # Configure Access Lists
# #    [Documentation]    Configure access lists for ping isolation
# #    ${cli}=             Write    access-lists ipv4 port_isolation_ping
# #    ${cli}=             Write    10 permit icmp host ${ipv4_2} host ${ipv4_3}
# #    ${cli}=             Write    20 permit icmp host ${ipv4_3} host ${ipv4_2}
# #    ${cli}=             Write    65535 permit ip any any


#############################
#lxc3_setup
#############################

Initial Configuration
    [Documentation]    Admin up interfaces ${host1.hostname}
    Switch Connection    ${host1.hostname}
    FOR    ${ports}    IN    @{host1.bundles}
    FOR    ${ph}    IN    @{ports.phy}
    FOR    ${ls}    IN    @{host1.ports}
    Write    interface physical ${ph}; admin-status up; link-speed ${ls.linkspeed}; commit
    Read Until Prompt
    END
    END
    END
    Commit Testcase

Create Bundles and VLANs
   [Documentation]     Configure bundles and VLANs
   Enter Config Mode
   Read Until Prompt
   
   FOR    ${num}    IN    @{host1.bundles}
   Write    bridge default; allowed-vlan add ${num.number},1000,1001
   Commit Testcase
   END

   FOR    ${bundle}    IN    @{host1.bundles}
   ${cli}=    Write    interface bundle ${bundle.number}
   FOR    ${port}    IN    @{bundle.port}
   ${cli}=    Write    port ${port}
   END
   ${cli}=    Write    mode ${bundle.mode}; lacp rate ${bundle.lacp_rate}; admin-status up
   Commit Testcase
   END

Configure VLANs and Bridge
   [Documentation]    Configure bridge and VLANs
   ${cli}=             Write    top;
   FOR    ${vlan}    IN    @{host1.bundles}
   ${cli}=             Write    bridge default; allowed-vlan add 23,${vlan.allowed_vlan};vlan 1000; irb enable; vlan 1001; irb enable;
   END
   ${cli}=             Write    vlan 23;
   Commit Testcase

Make bundle part of the bridge
   [Documentation]     Configure bundles in the bridge
   Write     top;
   Write    bridge default; allowed-vlan 1-1001;
   Commit Testcase
   FOR    ${port}    IN RANGE    1    ${counter}
   Write    interface bundle-${port}; mode trunk;
   Read Until Prompt
   END
   Commit Testcase

Trunk Configuration
   [Documentation]    Configure trunk for bundles
   FOR    ${bundle}    IN    @{host1.bundles}
   ${cli}=    Write    bridge default; interface bundle-${bundle.number} mode trunk
   ${cli}=    Write    trunk allowed vlan add ${bundle.allowed_vlan}
   ${cli}=    Write    trunk native vlan ${bundle.native_vlan}
   END
   Commit Testcase

Configure Interface
   [Documentation]    Set IP address for physical interface
   Write     top;
   FOR    ${bvi}    IN    @{host1.bvis}
   ${cli}=             Write    interface subif ${bvi.name}; admin-status up; ipv4 address ${bvi.ip} prefix ${bvi.prefix}
   END
   Write    top;
   # Route for hostpa
   FOR   ${pn}   IN   @{peer1.ospf.passive_network}
   Write    router static 0.0.0.0/0 next-hop ${pn}
   END
   Commit Testcase

# Configure UFD
#    [Documentation]    Set IP address for physical interface
#    Write     top;
#    ${ufd_group}=  Get From Dictionary    ${host1}    ufd_group
#    Log To Console    ${ufd_group}
#    Write   ufd group ${ufd_group["group_id"]}
#    Write   description "${ufd_group["description"]}"
#    Write   delay-up-time ${ufd_group["delay_up_time"]}
#    Write   support-tracking ${ufd_group["support_tracking"]}
#    Write   upstream ${ufd_group["upstream"]}
#    Configure UFD Downstream Interfaces    ${ufd_group["downstream"]}
   Write  do copy r s
   Commit Testcase

# Configure Access Lists
#    [Documentation]    Configure access lists for ping isolation
#    ${cli}=             Write    access-lists ipv4 port_isolation_ping
#    ${cli}=             Write    10 permit icmp host ${ipv4_2} host ${ipv4_3}
#    ${cli}=             Write    20 permit icmp host ${ipv4_3} host ${ipv4_2}
#    ${cli}=             Write    65535 permit ip any any


#############################
#lxc4_setup
#############################

Initial Configuration
    [Documentation]    Admin up interfaces ${host2.hostname}
    Switch Connection    ${host2.hostname}
    FOR    ${ports}    IN    @{host2.bundles}
    FOR    ${ph}    IN    @{ports.phy}
    FOR    ${ls}    IN    @{host2.ports}
    Write    interface physical ${ph}; admin-status up; link-speed ${ls.linkspeed}; commit
    Read Until Prompt
    END
    END
    END
    Commit Testcase

Create Bundles and VLANs
   [Documentation]     Configure bundles and VLANs
   Enter Config Mode
   Read Until Prompt
   
   FOR    ${num}    IN    @{host2.bundles}
   Write    bridge default; allowed-vlan add ${num.number},1000,1001
   Commit Testcase
   END

   FOR    ${bundle}    IN    @{host2.bundles}
   ${cli}=    Write    interface bundle ${bundle.number}
   FOR    ${port}    IN    @{bundle.port}
   ${cli}=    Write    port ${port}
   END
   ${cli}=    Write    mode ${bundle.mode}; lacp rate ${bundle.lacp_rate}; admin-status up
   Commit Testcase
   END

Configure VLANs and Bridge
   [Documentation]    Configure bridge and VLANs
   ${cli}=             Write    top;
   FOR    ${vlan}    IN    @{host2.bundles}
   ${cli}=             Write    bridge default; allowed-vlan add 45,${vlan.allowed_vlan}; vlan 1000; irb enable; vlan 1001; irb enable;
   END
   ${cli}=             Write    vlan 45;
   Commit Testcase

Make bundle part of the bridge
   [Documentation]     Configure bundles in the bridge
   Write     top;
   Write    bridge default; allowed-vlan 1-1001;
   Commit Testcase
   FOR    ${port}    IN RANGE    1    ${counter}
   Write    interface bundle-${port}; mode trunk;
   Read Until Prompt
   END
   Commit Testcase

Trunk Configuration
   [Documentation]    Configure trunk for bundles
   FOR    ${bundle}    IN    @{host2.bundles}
   ${cli}=    Write    bridge default; interface bundle-${bundle.number} mode trunk
   ${cli}=    Write    trunk allowed vlan add ${bundle.allowed_vlan}
   ${cli}=    Write    trunk native vlan ${bundle.native_vlan}
   END
   Commit Testcase

Configure Interface
   [Documentation]    Set IP address for physical interface
   Write     top;
   FOR    ${bvi}    IN    @{host2.bvis}
   ${cli}=             Write    interface subif ${bvi.name}; admin-status up; ipv4 address ${bvi.ip} prefix ${bvi.prefix}
   END
   FOR   ${pn}   IN   @{peer1.ospf.passive_network}
   Write    router static 0.0.0.0/0 next-hop ${pn}
   END
   Commit Testcase
   Write  do copy r s
   Commit Testcase


#############################
#lxc5_setup
#############################

Initial configuration
   [Documentation]     Admin up interfaces ${hostpa.hostname}
   Switch Connection    ${hostpa.hostname}
   # Loop through each port and allocate them
   FOR    ${port_num}    IN    @{hostpa.ports}
   Write     interface physical ${port_num.number}; admin-status up; link-speed ${port_num.linkspeed}; commit
   Read Until Prompt
   END
   Commit Testcase

Create Bundles and VLANs
   [Documentation]     Configure bundles and VLANs
   Enter Config Mode
   Read Until Prompt
   # FOR    ${num}    IN    @{hostpa.bundles}
   # Write    bridge default; allowed-vlan add ${num.number}
   # END
   Commit Testcase
   FOR    ${bundle}    IN    @{hostpa.bundles}
   ${cli}=    Write    interface bundle ${bundle.number}
   FOR    ${port}    IN    @{bundle.port}
   ${cli}=    Write    port ${port}
   END
   ${cli}=    Write    mode ${bundle.mode}; lacp rate ${bundle.lacp_rate}; admin-status up
   Commit Testcase
   END

Configure Loopback Interface
    [Documentation]   Configures loopback with IP
    Write   top;
    FOR    ${lb}    IN    @{hostpa.loopback}
    ${cli}=    Write    interface loopback 1; admin-status up; ipv4 address ${lb.ip} prefix ${lb.prefix}; commit
    END
    Commit Testcase

Configure to Spine
    [Documentation]   Configures the bundle to spine
    Write  top;
    FOR    ${bs}    IN    @{hostpa.bundles}
    ${cli}=             Write    interface bundle ${bs.number}; admin-status up; ipv4 address ${bs.ip} prefix ${bs.prefix}
    END
    Commit Testcase

Configurations for OSPF
  [Documentation]   Configures the ospf
    Write   top;
    Write   do autowizard false;
    FOR  ${ip}  IN  @{hostpa.loopback}
    Write   router ospf 1 ; router-id ${ip.ip} ; redistribute connected ; exit
    END
    Write   area 0
    FOR    ${bundle}    IN    @{hostpa['bundles']}
    ${ip}=    Get From Dictionary    ${bundle}    ip
    Write    network ${ip} ; authentication none
    END
    Commit Testcase
    Write  do copy r s
    Commit Testcase
