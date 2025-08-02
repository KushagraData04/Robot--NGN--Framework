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
${result}
${output}

*** Test Cases ***
###############
#physical setup
###############

Enable gtatuitous in DUT1
   [Documentation]  Configuration of Port ${DUT1.hostname}
   Switch Connection    ${DUT1.hostname}
   # Loop through each port and allocate them
   FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=  Write     arp gratuitous enable
   END
   Commit Testcase

Configure Bundles on DUT1 
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
  END
  Commit Testcase

Capture packets in DUT2 
    Open Connection    ${DUT_IP1}    alias=${DUT2.hostname}    prompt=${DUT_PROMPT2}    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
    Login    ${DUT_USERNAME_ROOT}    ${DUT_PASSWORD_ROOT}
    Switch Connection  ${DUT2.hostname}

    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
      Write   tcpdump -i bundle-${bundle.number} -nle arp -c 1 > gratuitous_arp.txt &
    END

Remove IP Address from Bundle in Dut1
    [Documentation]  Remove IP Address from Bundle
    Switch Connection    ${DUT1.hostname}
    FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
      ${cli}=  Write   interface bundle ${bundle.number}; no ipv4 address;
    END
    Commit Testcase

Configure Bundles and Ip on Bundle DUT1 bundle interfaces
  [Documentation]  Bundles Creation
  Switch Connection    ${DUT1.hostname}
  Enter Config Mode
  Read Until Prompt
  # Loop through each bundle and configure it with ports and mode
  FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
   ${cli}=    Write    interface bundle ${bundle.number}
   ${cli}=    Write    ipv4 address ${bundle.ip} prefix ${bundle.prefix}
   Commit Testcase
  END
  
Fetch Gratuitous ARP Packet
    Open Connection    ${DUT_IP1}    alias=${DUT2.hostname}    prompt=${DUT_PROMPT2}    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
    Login    ${DUT_USERNAME_ROOT}    ${DUT_PASSWORD_ROOT}
    Switch Connection  ${DUT2.hostname}

    ${output}=    Execute Command    cat gratuitous_arp.txt
    Log    ${output}

    ${bundle_ip}=    Get From Dictionary    ${DUT1.bundle_interfaces[0]}    ip
    Should Contain    ${output}    Request who-has ${bundle_ip} (ff:ff:ff:ff:ff:ff) tell ${bundle_ip}
    Close Connection 
    
