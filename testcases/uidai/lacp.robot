*** Settings ***
Documentation       LACP setup in STBR 117,130 and Falcon 118
Default Tags        LACP setup in STBR 117,130 and Falcon 118
Library             SSHLibrary
Variables           data/uidai.yaml
Resource            resource/monit.resource
Resource            resource/common.resource

*** Test Cases ***
################
#237.189 setup
################

Initial configuration
    Skip
    Switch Connection    R3
    [Documentation]     Admin up interfaces
    FOR    ${port}    IN    @{DUT1_Ports}
        Write     interface physical ${port};admin-status up;
        Write     lldp transmit
        Write     lldp receive
        Read Until Prompt
    END 
    Commit Testcase
Create bundle of the all interfaces
    Skip
   [Documentation]    Create bundle of all members
   Enter Config Mode
   Read Until Prompt
   FOR    ${port}    IN    @{DUT1_bundle_ports}
       ${cli}=    Write    interface bundle ${counter} 
       ${counter} =    Evaluate    ${counter} + 1
       ${cli}=    Write    port ${port}
       ${cli}=    Write    mode 802.3ad;lacp rate fast; admin-status up;
       Run Keyword If    ${counter} % 10 == 0    Commit Testcase
    END
    Commit Testcase
    Write     top;
    Write    bridge default; allowed-vlan 2-250;
    Commit Testcase
    FOR    ${port}    IN RANGE    1    ${counter}
        Write    interface bundle-${port};mode access;
        Read Until Prompt
    END
    Commit Testcase   

Set up stp on the bridge
    Skip
   # [Documentation]     Setting up stp on bridge
    ${cli}=             Write    top;
    ${cli}=             Write    bridge default; spanning-tree-type rstp;
    Commit Testcase
    ${cli}=             Write    rstp; priority 4096; commit
    Read Until Prompt
    Commit Testcase
    Set Global Variable    ${counter}    3
    

# #######################################
#     #FALCON-118
# ######################################


Create bundle and check states 
    Switch Connection    R5
    Set Global Variable    ${counter}    3
    [Documentation]     Admin up interfaces
    Write     interface physical ${falcon118_port}; breakout to-four;
    Write     sfp serdes-lane 4; sfp speed 40g;
    
    Commit Testcase
    Write    top;
    Read Until Prompt
    FOR    ${port}    IN    @{phy}
       Write     interface physical ${port};admin-status up;link-speed 10g;
    END
    Commit Testcase
    Write    top;
    FOR    ${port}    IN    @{falcon_bundle_ports}
       
       Write    interface bundle ${counter} 
       Read Until Prompt
       ${counter} =    Evaluate    ${counter} + 1
       Write    port ${port}
       Write    mode 802.3ad;lacp rate fast; admin-status up;
       Run Keyword If    ${counter} % 10 == 0    Commit Testcase
    END

    Commit Testcase
    Write     top;
    Write    bridge default; allowed-vlan 2-250;
    Commit Testcase
    FOR    ${port}    IN RANGE    3    ${counter}
        Write    interface bundle-${port};mode access;
        Read Until Prompt
    END
    Commit Testcase
    Set Global Variable    ${counter}    1
    Write     top;
    # Sleep     20s
    FOR    ${port}    IN RANGE    3    7
        
        Write    do show bundle interface bundle-${port}
        ${cli}=    Read Until Prompt
        Should Not Contain    ${cli}    defaulted
    END
    Write    top;
    Write    bridge default; spanning-tree-type rstp;
    Commit Testcase
    Write    rstp; priority 4096; commit
    Read Until Prompt
    Commit Testcase    
    Write       top
    FOR    ${port}    IN RANGE    3    7
        Write    do show spanning-tree interface bundle-${port}
        ${cli}=    Read Until Prompt
        Should Not Contain    ${cli}    Yes
    END

    # Write     top;
    # Read Until Prompt
    # Write        do show spanning-tree interface ${root_port} details | include state
    # ${cli}=    Read Until Prompt
    # Should Contain Any    ${cli}    Forwarding    down    
    # FOR    ${port}    IN RANGE    21    39
    #     Write    do show spanning-tree interface bundle-${port} 
    #     ${cli}=    Read Until Prompt
    #     Should Contain Any    ${cli}    Discarding    down
    # END  
    # FOR    ${port}    IN RANGE    1    20
        
    #     Write    do show spanning-tree interface bundle-${port} 
    #     ${cli}=    Read Until Prompt
    #     Should Contain Any    ${cli}    Forwarding    down
    # END
   
