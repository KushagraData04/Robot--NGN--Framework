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

Add prefix entries in DUT1 
    [Documentation]  Add prefix Time
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     ${cli}=  Write   interface subif ${bvi.name} ; 
     Write  ipv6 nd prefix ${DUT1.prefix}
    Commit Testcase
     END

     Write     top;

Enable no return address in prefix in DUT1
    [Documentation]  Enable no return address
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     ${cli}=  Write   interface subif ${bvi.name} ; 
     Write  ipv6 nd prefix ${DUT1.prefix} no-rtr-address enable
    Commit Testcase
     END

     Write     top;

# It is default in off-link
Disable off link in prefix in DUT1  
    [Documentation]  Enable off link flag
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     ${cli}=  Write   interface subif ${bvi.name} ; 
     Write  ipv6 nd prefix ${DUT1.prefix} off-link disable
    Commit Testcase
     END

     Write     top;

Change Preferred Lifetime in prefix in DUT1
    [Documentation]  Change Preferred Lifetime
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     ${cli}=  Write   interface subif ${bvi.name} ; 
     Write  ipv6 nd prefix ${DUT1.prefix} preferred-lifetime ${DUT1.preferred_life}
    Commit Testcase
     END

     Write     top;

Change Valid Lifetime in prefix in DUT1
    [Documentation]  Change Valid Lifetime
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
     ${cli}=  Write   interface subif ${bvi.name} ; 
     Write  ipv6 nd prefix ${DUT1.prefix} valid-lifetime ${DUT1.valid_life}
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
    Should Contain    ${output}    Flags [onlink, auto], valid time ${DUT1.valid_life}s, pref. time ${DUT1.preferred_life}s
        Close Connection
        Exit For Loop
    END
