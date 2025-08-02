*** Settings ***
Documentation       Configurations for lxc
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Library             OperatingSystem
Variables           ../../data/ipv4_arp.yaml
Resource            ../../resource/common.resource


*** Test Cases ***
###############
#physical setup
###############

Initial Port Configuration DUT1
   [Documentation]  Configuration of Port ${DUT1.hostname}
   Switch Connection    ${DUT1.hostname}
   # Loop through each port and allocate them
   FOR    ${port}    IN    @{DUT1.phy_interface}
    ${cli}=  Write  interface physical ${port.number}; link-speed ${port.linkspeed}; admin-status up; 
   END
   Commit Testcase

Configure IP Address on DUT1 Interfaces
   [Documentation]  Set IP Address on Physical Interface
   Write   top;
   Read Until Prompt
   FOR    ${phy}    IN    @{DUT1.phy_interface}
    ${cli}=  Write  interface physical ${phy.number} ; ipv4 address ${phy.ip} prefix ${phy.prefix}
   END
   Commit Testcase
   Write   top;

Configure IP Neighbour, MAC and Next Hop on the Interface
   [Documentation]  IPV4 Neighbour, MAC and Next Hop
   FOR    ${phy}    IN    @{DUT1.phy_interface}
    ${cli}=  Write  interface physical ${phy.number}
   END
   Write  ipv4 neighbour ${DUT1.ip_add} mac-address ${DUT1.mac_add}
   Commit Testcase

   # Open Connection    ${DUT_IP1}    alias=${DUT2.hostname}    prompt=${DUT_PROMPT2}      timeout=${DUT_TIMEOUT}     port=${DUT2.ssh_port}
   # Login    ${DUT_USERNAME_ROOT}    ${DUT_PASSWORD_ROOT}

# Validation of the IP and MAC
#    [Documentation]  Validation
#    Switch Connection    ${DUT2.hostname}
#    ${cli}=  Write  show ip next-hops global
#    ${cli}=  Read Until Prompt
#    Should Contain    ${cli}  ${DUT1.ip_add}
#    Should Contain    ${cli}  ${DUT1.mac_add}
#    Should Contain    ${cli}  static

Validate Next Hop Entry
   [Documentation]  Verify IP and MAC in Next-Hop Table
   # Execute Command  cli
   Write  top
   Write  do show ip next-hops global
   ${output}=  Read Until  ${DUT1.mac_add}
   Should Contain  ${output}  ${DUT1.ip_add} 
   ...    static 
   ...    ${DUT1.mac_add}
   Log   IP Neigh is: ${DUT1.ip_add}
   Log   MAC is: ${DUT1.mac_add}
   

# Validate Next Hop Entry
#    [Documentation]  Verify IP and MAC in Next-Hop Table
#    # Execute Command  cli
#    # Write  top
#    Write  do show ip next-hops global
#    ${output}=  Read Until  ${DUT1.mac_add}