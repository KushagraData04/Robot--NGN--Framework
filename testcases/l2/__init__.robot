*** Settings ***
Name                L2 Suite
Documentation       Contains L2 testcases
Library             SSHLibrary
Library             OperatingSystem
Variables           data/l2_suite.yaml
Resource            resource/common.resource
Suite Setup         Open all connections
Suite Teardown      Cleanup L2 Suite

*** Keywords ***
Open all connections
    # open connections on falcon cli, server SERVER, falcon root 
    Open Connection    ${DUT_IP}    alias=DUT    prompt=${DUT_PROMPT}      timeout=${DUT_TIMEOUT}
    Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
    Write    config; system cli prompt2 ${DUT_PROMPT};system cli notifications disable; commit; exit
    Read Until Prompt
    Write     config;
    Read Until Prompt
    FOR    ${port}    IN    @{falcon_Ports}
        Write     interface physical ${port};
        Run Keyword If    ${breakout}     Write     breakout ${breakout_mode};
    END    
    Commit Testcase
    Write    top;
    Read Until Prompt
    Write     interface physical ${phy};admin-status up;link-speed ${link-speed};
    Commit Testcase
    Sleep    5s
    
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
    Open Connection    ${DUT_IP}    alias=DUT_shell    prompt=${DUT_SHELL_PROMPT}      timeout=${DUT_SHELL_TIMEOUT}
    Login With Public Key    ${DUT_SHELL_USERNAME}    ${ID_RSA_PATH}
    # Run Keyword If    ${testing_on_hw}    Remove copp

Remove copp
    # remove copp from ldbg 
    Write    ldbg
    Read Until    LDPM_DEBUG $
    Write    hw copp remove
    Read Until    LDPM_DEBUG $
    Write    exit
    Read Until Prompt

Cleanup L2 Suite
    Switch Connection     DUT
    Reset Prompt
    Close All Connections
