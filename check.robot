*** Settings ***
Name                BVI
Documentation       Check BVI feature
Default Tags        Falcon 118
Library             SSHLibrary
Library             OperatingSystem
Variables           data/l2_suite.yaml
Resource            resource/erspan.resource
Resource            resource/common.resource
Suite Teardown      Cleanup
*** Test Cases ***
Open all connections   
    # open connections R2 
    Open Connection    192.168.111.117    alias=stbr    prompt=STBR-117#      timeout=30s
    Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
    Write    config; system cli prompt2 STBR-117# ;system cli notifications disable; commit; exit
    Read Until Prompt
    Write     config;
    Read Until Prompt

    # open connections R3 
    Open Connection    192.168.111.103    alias=falcon    prompt=CTX-3000-v01-111-103#      timeout=30s
    Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
    Write    config; system cli prompt2 CTX-3000-v01-111-103#;system cli notifications disable; commit; exit
    Read Until Prompt
    Write     config;
    Read Until Prompt
Physical ports creation
    Switch Connection    falcon
    FOR    ${port}    IN    @{falcon_breakout_ports}
        Write     interface physical ${port};
        Write     breakout to-four;
    END    
    Commit Testcase
    Write    top;
    
    Write     interface physical 1/ /1-4
    Write     admin-status up;
    Write     link-speed 10g

    Commit Testcase
    Write    top;

    Switch Connection    stbr
    FOR    ${port}      IN ZIP     ${R3_ports}       ${R3_ports_speed}
        Write     interface physical ${port};
        Write     admin-status up;
        Write     link-speed ${speed}
    END
    Commit Testcase
    Write    top;
