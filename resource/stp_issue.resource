*** Settings ***
Library             Process
Library             OperatingSystem
Library             SSHLibrary
Library             Collections
Library             String

*** Keywords ***
Commit Testcase
    Wait Until Keyword Succeeds    10x    30s   Commit Testcase internal
    
Commit Testcase internal
   ${cli}=    Write      commit;
   ${cli}=    Read Until Prompt  
   Should Contain Any    ${cli}    Commit complete    No modifications to commit
    
Enter Config Mode
    ${cli}=     Write     config;

Reset Prompt
   Write    top;no system cli prompt2; system cli notifications enable; commit
   ${output}=         Read Until Prompt

Write and wait
   [Arguments]    ${param1}
   Write     ${param1}
   Read Until Prompt

Get Second-to-Last Line
    [Arguments]    ${text}
    ${lines}=    Split To Lines    ${text}
    ${second_last_line}=    Get From List    ${lines}    -2
    RETURN    ${second_last_line}

Get Last Integer
    [Arguments]    ${text}
    ${words}=    Split String    ${text}
    ${last_word}=    Get From List    ${words}    -1
    ${int_value}=    Convert To Integer    ${last_word}
    RETURN    ${int_value}

Create Subif
    [Arguments]    ${iface}    ${vlan}    ${ip}    ${prefix}
    Write    interface subif ${iface}.${vlan}
    Write    admin-status up;
    Write    ipv4 address ${ip} prefix ${prefix}   
    
Check ldbg routes
    Switch Connection    DUT_shell
    # check routes programmed in ldpm
    Write    ldbg
    Read Until    LDPM_DEBUG $
    Write    ip 1 4 rt
    ${output}=     Read Until    LDPM_DEBUG $
    #Should Contain    ${output}    Current Route Count :      ${max_IPv4-Routes}
    Write    exit
    Read Until Prompt
make interface
    [Arguments]    ${cli}
    Write    top
    Write    interface physical ${cli};admin-status up;
    Commit Testcase

Add to bridge
    [Arguments]    ${cli}
    Write    top;bridge default
    Write    interface ${cli}; mode access;
    Commit Testcase

Remove from bridge
    [Arguments]    ${cli}
    Write    top;bridge default
    Write    no interface ${cli};
    Commit Testcase

Turn on stp
    Write    top; bridge default
    Write    spanning-tree-type stp
    Commit Testcase

Turn off stp
    Write    top;bridge default
    Write    no spanning-tree-type stp
    Commit Testcase

lua state check
    [Arguments]    ${filepath}    ${hw_port}
    Switch Connection    laptop
    Write    cpss-api call cpssDxChBrgSTpPortSpanningTreeStateGet devNum 0 portNum ${hw_port}
    ${output}=    Read Until    Console#
    ${lines}=    Split To Lines    ${output}
    ${second_last_line}=    Get From List    ${lines}    -5
    Append To File    path=${filepath}    content=${second_last_line}\n
    Switch Connection    lxc

lua state check stbr
    [Arguments]    ${filepath}    ${hw_port}
    Switch Connection    laptop
    Write    cpss-api call cpssDxChBrgStpStateGet dev 0 portNum ${hw_port} stpId 0
    ${output}=    Read Until    Console#
    ${lines}=    Split To Lines    ${output}
    ${second_last_line}=    Get From List    ${lines}    -5
    Append To File    path=${filepath}    content=${second_last_line}\n
    Switch Connection    lxc

Delete interface
    [Arguments]    ${cli}
    Write    top
    Write    no interface physical ${cli}
    Commit Testcase

Remove from bridge and delete interface
    [Arguments]    ${cli}    ${phy}
    Write    top;bridge default
    Write    no interface ${cli};
    Write    top
    Write    no interface physical ${phy}
    Commit Testcase

Remove bundle from bridge and delete 
    [Arguments]    ${cli}    
    Write    top;bridge default
    Write    no interface bundle-${cli};
    Write    top
    Write    no interface bundle ${cli}
    Commit Testcase
make bundle
    [Arguments]    ${id}    ${port}
    Write    top;interface bundle ${id}
    Write    port ${port};
    Write    mode loadbalance
    Write    admin-status up
    Commit Testcase

Add bundle to bridge    
    [Arguments]    ${id}
    Write    top;bridge default
    Write    interface bundle-${id}; mode access;
    Commit Testcase

Remove bundle from bridge
    [Arguments]    ${cli}
    Write    top;bridge default
    Write    no interface bundle-${cli};
    Commit Testcase 
