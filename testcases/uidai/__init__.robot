*** Settings ***
Name                L2 Suite
Documentation       Contains L2 testcases
Library             SSHLibrary
Library             OperatingSystem
Variables           data/uidai.yaml
Resource            resource/common.resource
Suite Setup         Open all connections
Suite Teardown      Cleanup uidai Suite


*** Keywords ***
Open all connections   
    #open connections R2 
    # Open Connection    ${R2_IP}    alias=R2    prompt=${R2_PROMPT}      timeout=${R2_TIMEOUT}
    # Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
    # Write    config; system cli prompt2 ${R2_PROMPT};system cli notifications disable; commit; exit
    # Read Until Prompt
    # Write     config;
    # Read Until Prompt

    # # open connections R3 
    # Open Connection    ${R3_IP}    alias=R3    prompt=${R3_PROMPT}      timeout=${R3_TIMEOUT}
    # Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
    # Write    config; system cli prompt2 ${R3_PROMPT};system cli notifications disable; commit; exit
    # Read Until Prompt
    # Write     config;
    # Read Until Prompt

    # # open connections R4 
    # Open Connection    ${R4_IP}    alias=R4    prompt=${R4_PROMPT}      timeout=${R4_TIMEOUT}
    # Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
    # Write    config; system cli prompt2 ${R4_PROMPT};system cli notifications disable; commit; exit
    # Read Until Prompt
    # Write     config;
    # Read Until Prompt

    # open connections R5 
    Open Connection    ${R5_IP}    alias=R5    prompt=${R5_PROMPT}      timeout=${R5_TIMEOUT}
    Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
    Write    config; system cli prompt2 ${R5_PROMPT};system cli notifications disable; commit; exit
    Read Until Prompt
    Write     config;
    Read Until Prompt
    Open Connection    ${SERVER_IP}    alias=SERVER    prompt=${SERVER_PROMPT}    timeout=${SERVER_TIMEOUT}
    Login    ${SERVER_USERNAME}    ${SERVER_PASSWORD}
    # once enter sudo in server as packet injection requires sudo 
    Write    sudo su
    Read Until     [sudo] password for ${SERVER_USERNAME}:
    Write          ${SERVER_PASSWORD}
    Write    exit
    Read Until Prompt

    ${HOME}=    Get Environment Variable    HOME
    ${ID_RSA_PATH}=    Set Variable    ${HOME}/.ssh/id_rsa
    Open Connection    ${R5_IP}    alias=DUT_shell    prompt=${DUT_SHELL_PROMPT}      timeout=${DUT_SHELL_TIMEOUT}
    Login With Public Key    ${DUT_SHELL_USERNAME}    ${ID_RSA_PATH}
    # # Run Keyword If    ${testing_on_hw}    Remove copp
Cleanup uidai Suite
    # Switch Connection     R2
    # Reset Prompt
    # Switch Connection     R3
    # Reset Prompt
    # Switch Connection     R4
    Reset Prompt
    Switch Connection     R5
    Reset Prompt
    Close All Connections
