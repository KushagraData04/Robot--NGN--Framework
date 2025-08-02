*** Settings ***
Documentation       Opening the Connections
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Suite Setup         Open all connections
Variables           ../../data/ipv4.yaml
Resource            ../../resource/common.resource


*** Keywords ***
Open all connections
   Open Connection    ${DUT_IP1}    alias=${DUT1.hostname}    prompt=${DUT_PROMPT1}      timeout=${DUT_TIMEOUT}     port=${DUT1.ssh_port}
   Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
   Write    config; system cli prompt2 ${DUT_PROMPT1}; system cli notifications disable; commit; exit
   Read Until Prompt
   Write     config;
   Read Until Prompt
   Open Connection    ${DUT_IP2}    alias=${DUT2.hostname}    prompt=${DUT_PROMPT2}      timeout=${DUT_TIMEOUT}     port=${DUT2.ssh_port}
   Login    ${DUT_USERNAME1}    ${DUT_PASSWORD1}
   Write    cli
   sleep  2s
   # Read Until  root@falconPEGA-111-229:~#
   Write    config; system cli prompt2 ${DUT_PROMPT2}; system cli notifications disable; commit; exit
   Read Until Prompt
   Write     config;
   Read Until Prompt
   Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
   Login    ngn    ngn@8737