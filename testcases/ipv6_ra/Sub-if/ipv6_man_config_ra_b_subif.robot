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
  END
  Commit Testcase

Configure IP Address on DUT1 Bundle Subif Interfaces
  [Documentation]    Set IP address for bundle interface
  Switch Connection    ${DUT1.hostname}
  Write     top;
  FOR    ${subif}    IN    @{DUT1.bundle_subif_interfaces}
   Write     interface subif ${subif.name}; admin-status up; ipv6 address ${subif.ipv6} prefix ${subif.prefix}
   Commit Testcase
  END

No Suppress RA in Dut1
    [Documentation]  Set No Suppress RA
    FOR    ${subif}    IN    @{DUT1.bundle_subif_interfaces}
     ${cli}=  Write   interface subif ${subif.name} ; 
     Write  ipv6 nd no-suppress-ra enable
    Commit Testcase
     END

     Write     top;

Check the manage config in Dut1
    [Documentation]  Set Check the manage config 
    Switch Connection    ${DUT1.hostname}
    FOR    ${subif}    IN    @{DUT1.bundle_subif_interfaces}
        Write    interface subif ${subif.name}
        Write  ipv6 nd managed-config-flag enable
    END
    Commit Testcase

    #  Write     top;

Check packets in DUT2
   [Documentation]  Check packets
    Open Connection    ${DUT_IP1}    alias=${DUT2.hostname}    prompt=${DUT_PROMPT2}    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
    Login    ${DUT_USERNAME_ROOT}    ${DUT_PASSWORD_ROOT}
    Switch Connection  ${DUT2.hostname}

    FOR    ${subif}    IN    @{DUT1.bundle_subif_interfaces}
        Write    timeout 20 bash -c "sudo tcpdump -i ${subif.name} -c 3 -vvv -s0 -n 'icmp6 and ip6[40] == 134'"
    ${output}=    Read Until Prompt
    Log    ${output}
    ${match}=    Evaluate    'Flags [managed]' in """${output}""" or 'Flags [managed, other stateful]' in """${output}"""
    Run Keyword If    ${match}    Log    Flags match found
...    ELSE    Fail    Flags not found in output
    
   Exit For Loop
   END

