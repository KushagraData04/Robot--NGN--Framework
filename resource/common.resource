*** Settings ***
Library             Process
Library             OperatingSystem
Library             SSHLibrary
Library             Collections
Library             String

*** Keywords ***
Commit Testcase
    Wait Until Keyword Succeeds    30x    10s   Commit Testcase internal
check state
    [Arguments]    ${iface}
    Wait Until Keyword Succeeds    100x    5s    check oper up    ${iface}
check oper up
    [Arguments]    ${iface}
    Write    do show interface configuration brief ${iface} oper-status
    ${op}=    Read Until Prompt
    Should Contain    ${op}    oper-status up 
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

Get Third Last Integer
    [Arguments]    ${text}
    ${words}=    Split String    ${text}
    ${last_word}=    Get From List    ${words}    -3
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