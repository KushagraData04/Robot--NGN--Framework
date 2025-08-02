*** Settings ***
Documentation       Test Cases
Library             SSHLibrary
Library             pandas
Library             re
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Resource            ./common.resource

*** Keywords ***
Login To Device
    [Arguments]    ${username}    ${password}
    Login    ${username}    ${password}

Run Command
    [Arguments]    ${command}
    ${output}=     Execute Command    ${command}
    RETURN       ${output}

Compare Outputs
    [Arguments]    ${output1}    ${output2}
    Run Keyword If    '${output1}' == '${output2}'   Log To Console    Outputs match    ELSE    Log To Console    Outputs differ

Get Matches Using Regex
    [Arguments]      ${data}     ${pattern}    
    Log To Console   data : ${data}
    ${result}=       Evaluate    re.findall(${pattern}, ${data})
    RETURN        ${result}

Create DataFrame From Matches
    [Arguments]      ${matches}     ${columns}
    ${df}=           Evaluate       pandas.DataFrame(${matches}, columns=${columns})
    RETURN         ${df}

Get MAC Address
    [Arguments]     ${text}     ${key}
    #${index}=       Run Keyword And Return     Get Line     ${text}    ${key}
    #${index}=    Run Keyword And Return    Get Line    ${text}    \[Peer Link Mac\]
    ${index}=    Get Lines Containing String    ${text}    ${key} 
    #${line}=    Get Lines Containing String   ${text}    ${index}
    #${mac}=    Fetch MAC from Line    ${line}
    ${mac}=    Fetch MAC from Line    ${index}
    RETURN        ${mac}

Get Line
    [Arguments]     ${text}    ${index}
    ${lines}=       Split String    ${text}    \n
    RETURN        ${lines}[${index}]

# Fetch MAC from Line
#     [Arguments]     ${line}
#     ${mac}=         Evaluate    re.search(r"([0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2})", '''${line}''')
#     #${mac}=          Evaluate    re.findall(r'^.* Peer Link Mac:\s*:\s*.*$', """${line}""", re.MULTILINE)
#     RETURN       ${mac}

Fetch MAC from Line
    [Arguments]     ${line}
    ${match}=         Evaluate    re.search(r"([0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2})", '''${line}''')
    Run Keyword If    ${match}    Set Variable    ${match.group(1)}    ELSE    Fail    "No MAC address found in line: ${line}"
    RETURN            ${match.group(1)}

# Retrieve ARP Entries
#     [Arguments]    ${hostname}
#     Switch Connection    ${hostname}
#     ${arp_data}=    Run Command    show mclag index 1 arp
#     RETURN    ${arp_data}

Extract System IDs
    [Arguments]    ${lxc1}    ${lxc2}
    ${lines1}=     Split String    ${lxc1}    \n
    ${lines2}=     Split String    ${lxc2}    \n
    ${bundle1_lxc1}    Set Variable    ${EMPTY}
    ${bundle23_lxc1}   Set Variable    ${EMPTY}
    ${bundle45_lxc1}   Set Variable    ${EMPTY}
    ${bundle1_lxc2}    Set Variable    ${EMPTY}
    ${bundle23_lxc2}   Set Variable    ${EMPTY}
    ${bundle45_lxc2}   Set Variable    ${EMPTY}

    FOR    ${line}    IN    @{lines1}
        ${columns}=    Split String    ${line}    ${SPACE}
        ${bundle_id}=  Get From List   ${columns}    0
        ${system_id}=  Get From List   ${columns}    8

        Run Keyword If    '${bundle_id}' == '1'       Set Variable    ${bundle1_lxc1}    ${system_id}
        Run Keyword If    '${bundle_id}' == '23'      Set Variable    ${bundle23_lxc1}   ${system_id}
        Run Keyword If    '${bundle_id}' == '45'      Set Variable    ${bundle45_lxc1}   ${system_id}
    END

    FOR    ${line}    IN    @{lines2}
        ${columns}=    Split String    ${line}    ${SPACE}
        ${bundle_id}=  Get From List   ${columns}    0
        ${system_id}=  Get From List   ${columns}    8

        Run Keyword If    '${bundle_id}' == '1'       Set Variable    ${bundle1_lxc2}    ${system_id}
        Run Keyword If    '${bundle_id}' == '23'      Set Variable    ${bundle23_lxc2}   ${system_id}
        Run Keyword If    '${bundle_id}' == '45'      Set Variable    ${bundle45_lxc2}   ${system_id}
    END

    Log    Bundle 1 System ID (LXC1): ${bundle1_lxc1}
    Log    Bundle 23 System ID (LXC1): ${bundle23_lxc1}
    Log    Bundle 45 System ID (LXC1): ${bundle45_lxc1}
    Log    Bundle 1 System ID (LXC2): ${bundle1_lxc2}
    Log    Bundle 23 System ID (LXC2): ${bundle23_lxc2}
    Log    Bundle 45 System ID (LXC2): ${bundle45_lxc2}
