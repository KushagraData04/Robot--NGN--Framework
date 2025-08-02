*** Settings ***
Documentation       Configurations for lxc
Library             SSHLibrary
Library             Process
Library             String
Library             Collections
Library             OperatingSystem
Variables           ../../../data/ipv4_arp.yaml
Resource            ../../../resource/common.resource
Resource            ../../../testcases/ipv4robot/ip_route.resource


*** Test Cases ***
###############
#physical setup
###############

Initial Port Configuration DUT1
   [Documentation]  Configuration ${DUT1.hostname}
   Switch Connection    ${DUT1.hostname}
   # Loop through each port and allocate them
   FOR    ${port}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write   interface physical ${port.number}; link-speed ${port.linkspeed}; admin-status up; 
    Commit Testcase
   END

Configure Bundles and Ip on Bundle DUT1 bundle interfaces
  [Documentation]  Bundles Creation
  Switch Connection    ${DUT1.hostname}
  Enter Config Mode
  Read Until Prompt
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
    ${cli}=    Write    ipv6 address ${bundle.ipv6} prefix ${bundle.prefix6}; ipv6 enable
    Commit Testcase
  END

No Suppress RA in Dut1
    [Documentation]  Set No Suppress RA
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
     Write  ipv6 nd no-suppress-ra enable
    Commit Testcase
     END

     Write     top;

Remove the manage config in DUT1
    [Documentation]  Disable manage config flag
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
     Write  ipv6 nd managed-config-flag disable
    Commit Testcase
     END

     Write     top;

Remove the Link MTU in DUT1
    [Documentation]  Remove the Link MTU 
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
     Write  no ipv6 nd ra-link-mtu
    Commit Testcase
     END

     Write     top;

Remove Other Config Flag in DUT1
    [Documentation]  Disable other config flag
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
     Write  ipv6 nd other-config-flag disable
    Commit Testcase
     END

     Write     top;

Remove Advertisement Interval in DUT1
    [Documentation]  Remove Advertisement Interval 
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
     Write  ipv6 nd advertisement-interval disable
    Commit Testcase
     END

     Write     top;

Remove hop limit in DUT1
    [Documentation]  Remove hop limit
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
      Write  no ipv6 nd ra-hop-limit
    Commit Testcase
     END

     Write     top;

Remove lifetime in DUT1
    [Documentation]  Remove Lifetime 
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
      Write  no ipv6 nd ra-lifetime
    Commit Testcase
     END

     Write     top;

Remove reachable time in DUT1
    [Documentation]  Remove reachable time 
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
      Write  no ipv6 nd ra-reachable-time
    Commit Testcase
     END

     Write     top;

Remove retransmit time in DUT1
    [Documentation]  Remove retransmit time
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
      Write  no ipv6 nd ra-retransmit-time
    Commit Testcase
     END

     Write     top;

Enable off link in prefix in DUT1
    [Documentation]  Enable off link
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
      Write  ipv6 nd prefix ${DUT1.prefix} off-link enable
    Commit Testcase
     END

     Write     top;

Disable no return address in prefix in DUT1
    [Documentation]  Disble no return address
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
      Write  ipv6 nd prefix ${DUT1.prefix} no-rtr-address disable
    Commit Testcase
     END

     Write     top;

Check packets in DUT2
   [Documentation]  Check packets
    Open Connection    ${DUT_IP1}    alias=${DUT2.hostname}    prompt=${DUT_PROMPT2}    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
    Login    ${DUT_USERNAME_ROOT}    ${DUT_PASSWORD_ROOT}
    Switch Connection  ${DUT2.hostname}

    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
    Write    timeout 20 bash -c "sudo tcpdump -i bundle-${bundle.number} -c 3 -vvv -s0 -n 'icmp6 and ip6[40] == 134'"
    ${output}=    Read Until Prompt
    Log    ${output}
    Should Contain    ${output}    router advertisement    
   Exit For Loop
   END
