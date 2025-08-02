*** Settings ***
Library             Process
Library             OperatingSystem
Library             SSHLibrary

*** Keywords ***
Commit Testcase
    Wait Until Keyword Succeeds    3x    90     Commit Testcase Internal

Commit Testcase Internal
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