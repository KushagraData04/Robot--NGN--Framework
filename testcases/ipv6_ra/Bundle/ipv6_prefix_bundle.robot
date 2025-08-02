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

Add prefix entries in DUT1 
    [Documentation]  Add prefix Time
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
     Write  ipv6 nd prefix ${DUT1.prefix}
    Commit Testcase
     END

     Write     top;

Enable no return address in prefix in DUT1
    [Documentation]  Enable no return address
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
     Write  ipv6 nd prefix ${DUT1.prefix} no-rtr-address enable
    Commit Testcase
     END

     Write     top;

# It is default in off-link
Disable off link in prefix in DUT1  
    [Documentation]  Enable off link flag
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
     Write  ipv6 nd prefix ${DUT1.prefix} off-link disable
    Commit Testcase
     END

     Write     top;

Change Preferred Lifetime in prefix in DUT1
    [Documentation]  Change Preferred Lifetime
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
     Write  ipv6 nd prefix ${DUT1.prefix} preferred-lifetime ${DUT1.preferred_life}
    Commit Testcase
     END

     Write     top;

Change Valid Lifetime in prefix in DUT1
    [Documentation]  Change Valid Lifetime
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write   interface bundle ${bundle.number} ; 
     Write  ipv6 nd prefix ${DUT1.prefix} valid-lifetime ${DUT1.valid_life}
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
    Should Contain    ${output}    Flags [onlink, auto], valid time ${DUT1.valid_life}s, pref. time ${DUT1.preferred_life}s
    
   Exit For Loop
   END
