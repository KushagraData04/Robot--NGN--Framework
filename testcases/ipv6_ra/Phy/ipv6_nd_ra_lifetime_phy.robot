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

IPV6 enalbe on DUT1 Interfaces
   [Documentation]    Ipv6 enable physical interface
   Write     top;
   Read Until Prompt
   FOR    ${phy}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write   interface physical ${phy.number} ; ipv6 enable
    Commit Testcase 
   END
   Write     top;

No Suppress ra in Dut1
    [Documentation]  No Suppress ra
    FOR    ${phy}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write   interface physical ${phy.number} ; 
      Write  ipv6 nd no-suppress-ra enable
     END
     Commit Testcase
     Write     top;

ND RA Lifetime in DUT1
    [Documentation]  RA lifetime limit
    FOR    ${phy}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write   interface physical ${phy.number} ; 
      Write  ipv6 nd ra-lifetime ${DUT1.lifetime}
     END
     Commit Testcase
     Write     top;


Check packets on DUT2
    Open Connection    ${DUT_IP1}    alias=${DUT2.hostname}    prompt=${DUT_PROMPT2}    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
    Login    ${DUT_USERNAME_ROOT}    ${DUT_PASSWORD_ROOT}
    Switch Connection  ${DUT2.hostname}

    Write    timeout 20 bash -c "sudo tcpdump -i ${DUT1.l_name} -c 3 -vvv -s0 -n 'icmp6 and ip6[40] == 134'"
    ${output}=    Read Until Prompt
    Log    ${output}
    Should Contain    ${output}    router lifetime ${DUT1.lifetime}s
    Close Connection

