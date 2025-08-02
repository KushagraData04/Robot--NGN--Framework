*** Settings ***
Documentation       Configurations for lxc
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Library             OperatingSystem
Variables           ../../../data/ipv4_arp.yaml
Resource            ../../../resource/common.resource

*** Variables ***
${output}

*** Test Cases ***
###############
#physical setup
###############

Enablr gtatuitous in DUT1
   [Documentation]  Configuration of Port ${DUT1.hostname}
   Switch Connection    ${DUT1.hostname}
   # Loop through each port and allocate them
   FOR    ${port}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write     arp gratuitous enable
   END
   Commit Testcase

Initial Port Configuration DUT1
   [Documentation]  Set intraface configuration for ${DUT1.hostname}
   Switch Connection    ${DUT1.hostname}
   # Loop through each port and allocate them
   FOR    ${port}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write    interface physical ${port.number}; link-speed ${port.linkspeed}; admin-status up; 
   END
   Commit Testcase

Capture packets in DUT2 
    Open Connection    ${DUT_IP1}    alias=${DUT2.hostname}    prompt=${DUT_PROMPT2}    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
    Login    ${DUT_USERNAME_ROOT}    ${DUT_PASSWORD_ROOT}
    Switch Connection  ${DUT2.hostname}

  Write   tcpdump -i ${DUT1.l_name} -nle arp -c 1 > gratuitous_arp.txt &

Clean Up Existing IP Address on DUT1 Interfaces
  [Documentation]  Configuration of Port ${DUT1.hostname}
   Switch Connection    ${DUT1.hostname}
   Write     top;
   Read Until Prompt
   FOR    ${phy}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write     interface physical ${phy.number} ; no ipv4 address ${phy.ip}
   END
  Commit Testcase

Configure IP Address on DUT1 Interfaces
  [Documentation]  Configuration of Port ${DUT1.hostname}
   Switch Connection    ${DUT1.hostname}
   Write     top;
   Read Until Prompt
   FOR    ${phy}    IN    @{DUT1.phy_interfaces}
     ${cli}=  Write     interface physical ${phy.number} ; ipv4 address ${phy.ip} prefix ${phy.prefix}
   END
   Commit Testcase

Fetch Gratuitous ARP Packet
    Open Connection    ${DUT_IP1}    alias=${DUT2.hostname}    prompt=${DUT_PROMPT2}    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
    Login    ${DUT_USERNAME_ROOT}    ${DUT_PASSWORD_ROOT}
    Switch Connection  ${DUT2.hostname}

    ${output}=    Execute Command    cat gratuitous_arp.txt
    Log    ${output}
    Should Contain    ${output}    Request who-has ${DUT1.phy_interfaces[0].ip} (ff:ff:ff:ff:ff:ff) tell ${DUT1.phy_interfaces[0].ip}
    
    Close Connection 

  

