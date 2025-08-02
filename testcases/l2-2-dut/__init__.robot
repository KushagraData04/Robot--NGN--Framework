*** Settings ***
Name                L2 Suite
Documentation       Contains L2 testcases
Library             SSHLibrary
Library             OperatingSystem
Variables           data/l2-2-dut_suite.yaml
Resource            resource/common.resource
Suite Setup         Open all connections
Suite Teardown      Cleanup L2 Suite

*** Keywords ***
Open all connections
    
    # open connections DUT1 
    Open Connection    ${DUT1_IP}    alias=DUT1    prompt=${DUT1_PROMPT}      timeout=${DUT1_TIMEOUT}
    Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
    Write    config; system cli prompt2 ${DUT1_PROMPT};system cli notifications disable; commit; exit
    Read Until Prompt
    Write     config;
    Read Until Prompt

    # open connections DUT2 
    Open Connection    ${DUT2_IP}    alias=DUT2    prompt=${DUT2_PROMPT}      timeout=${DUT2_TIMEOUT}
    Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
    Write    config; system cli prompt2 ${DUT2_PROMPT};system cli notifications disable; commit; exit
    Read Until Prompt
    Write     config;
    Read Until Prompt

Cleanup L2 Suite
    Switch Connection     DUT1
    Reset Prompt
    Switch Connection     DUT2
    Reset Prompt
    Close All Connections
