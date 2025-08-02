*** Settings ***
Name                L2 Suite
Documentation       Contains L2 testcases
Library             SSHLibrary
Library             OperatingSystem
Variables           data/newfile.yaml
Resource            resource/common.resource
Suite Setup         Open all connections
Suite Teardown      Close All Connections

*** Test Cases ***
Physical ports creation
    Skip
    Switch Connection    R2
    FOR    ${port}    IN    @{R2_breakout_ports}
        Write     interface physical ${port};
        Write     breakout to-four;
    END    
    Commit Testcase
    Write    top;
    FOR    ${port}    ${speed}    IN ZIP     ${R2_ports}       ${R2_ports_speed}
        Write     interface physical ${port};
        Write     admin-status up;
        Write     link-speed ${speed}
    END
    Commit Testcase
    Write    top;

    Switch Connection    R3
    FOR    ${port}    ${speed}    IN ZIP     ${R3_ports}       ${R3_ports_speed}
        Write     interface physical ${port};
        Write     admin-status up;
        Write     link-speed ${speed}
    END
    Commit Testcase
    Write    top;

lag creation
    Skip
    Switch Connection    R2
    FOR    ${port}    ${id}    IN ZIP     ${R2_bundle_ports}       ${lag_id}
        Write     interface bundle ${id};
        Write     admin-status up;
        Write     port ${port}
        Write     mode 802.3ad;
    END
    Commit Testcase
    Write    top;
     Switch Connection    R3
    FOR    ${port}    ${id}    IN ZIP     ${R3_bundle_ports}       ${stbr_lag1d}
        Write     interface bundle ${id};
        Write     admin-status up;
        Write     port ${port}
        Write     mode 802.3ad;
    END
    Commit Testcase
    Write    top;
    
bridge lag addition
    Skip
    Switch Connection    R2
    Write    bridge default; spanning-tree-type rstp;
    FOR    ${port}    ${id}    IN ZIP     ${R2_bundle_ports}       ${lag_id}
        Write     interface bundle-${id};
        Write     mode access;
    END
    Commit Testcase
    Write    top;
    Switch Connection    R3
    Write    bridge default; spanning-tree-type rstp;
    FOR    ${port}    ${id}    IN ZIP     ${R3_bundle_ports}       ${stbr_lag1d}
        Write     interface bundle-${id};
        Write     mode access;
    END
    Commit Testcase
    Write    top;

cleanup
    Switch Connection    R2
    # Write    bridge default;
    # FOR    ${port}    ${id}    IN ZIP     ${R2_bundle_ports}       ${lag_id}
    #     Write     no interface bundle-${id};
    # END
    # Commit Testcase
    # Write     top
    # FOR    ${port}    ${id}    IN ZIP     ${R3_bundle_ports}       ${lag_id}
    #     Write     no interface bundle ${id};
    # END
    # Commit Testcase
    # Write    top;
    Switch Connection    R3
    Write    bridge default;
    FOR    ${port}    ${id}    IN ZIP     ${R3_bundle_ports}       ${stbr_lag1d}
        Write     no interface bundle-${id};
    END
    Commit Testcase
    Write     top
    FOR    ${port}    ${id}    IN ZIP     ${R3_bundle_ports}       ${stbr_lag1d}
        Write     no interface bundle ${id};
    END
    Commit Testcase
    Write    top;

*** Keywords ***
Open all connections   
    # open connections R2 
    Open Connection    ${R2_IP}    alias=R2    prompt=${R2_PROMPT}      timeout=${R2_TIMEOUT}
    Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
    Write    config; system cli prompt2 ${R2_PROMPT};system cli notifications disable; commit; exit
    Read Until Prompt
    Write     config;
    Read Until Prompt

    # open connections R3 
    Open Connection    ${R3_IP}    alias=R3    prompt=${R3_PROMPT}      timeout=${R3_TIMEOUT}
    Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
    Write    config; system cli prompt2 ${R3_PROMPT};system cli notifications disable; commit; exit
    Read Until Prompt
    Write     config;
    Read Until Prompt