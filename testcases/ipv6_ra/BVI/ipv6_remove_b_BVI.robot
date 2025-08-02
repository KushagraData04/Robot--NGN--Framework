*** Settings ***
Documentation       Configurations for bundle BVI interfaces on DUT1
Library             SSHLibrary
Library             Process
Library             String
Library             Collections
Library             OperatingSystem
Variables           ../../../data/ipv4_arp.yaml
Resource            ../../../resource/common.resource
Resource            ../../../testcases/ipv4robot/ip_route.resource

*** Test Cases ***
Configure DUT1 Bundles 
  [Documentation]  Bundles Creation
  Switch Connection    ${DUT1.hostname}
#   Read Until Prompt
  # Loop through each bundle and configure it with ports and mode
  FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
  ${cli}=    Write    interface bundle ${bundle.number}
     FOR    ${port}    IN    @{bundle.port}
      ${cli}=    Write    port ${port}
     END
     ${cli}=    Write    mode ${bundle.mode}; admin-status up
  
     IF  "${bundle.mode}" != "loadbalance"
      ${cli}=    Write   lacp rate ${bundle.lacp_rate};
     END
     Commit Testcase
  END

BVI over Bundle Interface Configuration DUT1
  [Documentation]  BVI over PHY Interfaces Configuration
  Switch Connection    ${DUT1.hostname}
    Write   top;
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     Write   bridge default; allowed-vlan add ${bvi.allowed_vlan}; vlan ${bvi.allowed_vlan}; irb enable 
     Write   bridge default interface ${bvi.port} mode trunk ; trunk allowed vlan add ${bvi.allowed_vlan} 
     Commit Testcase
     Write     top;
     Write   interface subif ${bvi.name}; ipv6 address ${bvi.ipv6} prefix ${bvi.prefix6} ; admin-status up
     Commit Testcase
    END

Enable No Suppress RA on Bundle BVI
    [Documentation]    Enable RA advertisement on BVI interfaces
    Switch Connection    ${DUT1.hostname}
    
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
        Write    interface subif ${bvi.name}
        Write    ipv6 nd no-suppress-ra enable
        Commit Testcase
    END
    Write    top;

Remove the manage config in DUT1
    [Documentation]  Disable manage config flag
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     ${cli}=  Write   interface subif ${bvi.name} ; 
     Write  ipv6 nd managed-config-flag disable
    Commit Testcase
     END

     Write     top;

Remove the Link MTU in DUT1
    [Documentation]  Remove the Link MTU 
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     ${cli}=  Write   interface subif ${bvi.name} ; 
     Write  no ipv6 nd ra-link-mtu
    Commit Testcase
     END

     Write     top;

Remove Other Config Flag in DUT1
    [Documentation]  Disable other config flag
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     ${cli}=  Write   interface subif ${bvi.name} ; 
     Write  ipv6 nd other-config-flag disable
    Commit Testcase
     END

     Write     top;

Remove Advertisement Interval in DUT1
    [Documentation]  Remove Advertisement Interval 
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     ${cli}=  Write   interface subif ${bvi.name} ; 
     Write  ipv6 nd advertisement-interval disable
    Commit Testcase
     END

     Write     top;

Remove hop limit in DUT1
    [Documentation]  Remove hop limit
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     ${cli}=  Write   interface subif ${bvi.name} ; 
      Write  no ipv6 nd ra-hop-limit
    Commit Testcase
     END

     Write     top;

Remove lifetime in DUT1
    [Documentation]  Remove Lifetime 
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     ${cli}=  Write   interface subif ${bvi.name} ; 
      Write  no ipv6 nd ra-lifetime
    Commit Testcase
     END

     Write     top;

Remove reachable time in DUT1
    [Documentation]  Remove reachable time 
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     ${cli}=  Write   interface subif ${bvi.name} ; 
      Write  no ipv6 nd ra-reachable-time
    Commit Testcase
     END

     Write     top;

Remove retransmit time in DUT1
    [Documentation]  Remove retransmit time
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     ${cli}=  Write   interface subif ${bvi.name} ; 
      Write  no ipv6 nd ra-retransmit-time
    Commit Testcase
     END

     Write     top;

Enable off link in prefix in DUT1
    [Documentation]  Enable off link
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     ${cli}=  Write   interface subif ${bvi.name} ; 
      Write  ipv6 nd prefix ${DUT1.prefix} off-link enable
    Commit Testcase
     END

     Write     top;

Disable no return address in prefix in DUT1
    [Documentation]  Disble no return address
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     ${cli}=  Write   interface subif ${bvi.name} ; 
      Write  ipv6 nd prefix ${DUT1.prefix} no-rtr-address disable
    Commit Testcase
     END

     Write     top;

Check RA Packets on DUT2 from BVI
    [Documentation]    Check Router Advertisements from DUT1 BVI interfaces on DUT2
    Open Connection    ${DUT_IP1}    alias=${DUT2.hostname}    prompt=${DUT_PROMPT2}    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
    Login    ${DUT_USERNAME_ROOT}    ${DUT_PASSWORD_ROOT}
    Switch Connection    ${DUT2.hostname}

    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
        Write    timeout 20 bash -c "sudo tcpdump -i ${bvi.name} -c 3 -vvv -s0 -n 'icmp6 and ip6[40] == 134'"
    ${output}=    Read Until Prompt
    Log    ${output}
    Should Contain    ${output}    router advertisement 
        Close Connection
        Exit For Loop
    END
