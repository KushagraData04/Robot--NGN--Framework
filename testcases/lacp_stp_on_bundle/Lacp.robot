*** Settings ***
Documentation       LACP setup in STBR 117,130 and Falcon 118
Default Tags        LACP setup in STBR 117,130 and Falcon 118
Library             SSHLibrary
Variables           ../../data/lacp.yaml
Resource            ../../resource/common.resource
Suite Setup         Open all connections
Suite Teardown      Close All Connections


*** Test Cases ***
################
#STBR-117 setup
################

Enter config mode
    Open Connection    ${DUT1_IP}    alias=DUT1    prompt=${DUT1_PROMPT}      timeout=${DUT1_TIMEOUT}
    Login    ${DUT1_USERNAME}    ${DUT1_PASSWORD}
    Write    config; system cli prompt2 STBR-117#;system cli notifications disable; commit; exit
    Read Until Prompt
    Write     config;
    Read Until Prompt

Initial configuration
    [Documentation]     Admin up interfaces
    FOR    ${port}    IN    @{DUT1_Ports}
        Write     interface physical ${port};admin-status up;
        Write     lldp transmit
        Write     lldp receive
        Read Until Prompt
    END 
    Commit Testcase

Create bundle of the all interfaces
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
   # [Documentation]     Setting up stp on bridge
    ${cli}=             Write    top;
    ${cli}=             Write    bridge default; spanning-tree-type rstp;
    Commit Testcase
    ${cli}=             Write    rstp; priority 4096; commit
    Read Until Prompt
    Commit Testcase
    Set Global Variable    ${counter}    1
    

#################
#    STBR-130
#################
Enter config mode
    Switch Connection     stbr130
    Write    config; system cli prompt2 STBR-130#;system cli notifications disable; commit; exit
    Read Until Prompt
    Write     config;
    Read Until Prompt

Initial configuration
    [Documentation]     Admin up interfaces
    FOR    ${port}    IN    @{stbr130_Ports}
        Write     interface physical ${port};admin-status up;
        Write     lldp transmit
        Write     lldp receive
        Read Until Prompt
    END 
    Commit Testcase

Create bundle of the all interfaces
   [Documentation]    Create bundle of all members
   
   FOR    ${port}    IN    @{stbr130_bundle_ports}
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
    FOR    ${port}    IN RANGE    1    ${counter}
        Write    interface bundle-${port};mode access;
        Read Until Prompt
    END
    Commit Testcase
    Set Global Variable    ${counter}    1    
    
Set up stp on the bridge
   # [Documentation]     Setting up stp on bridge
    ${cli}=             Write    top;
    ${cli}=             Write    bridge default; spanning-tree-type rstp;
    Commit Testcase
    ${cli}=             Write    rstp; priority 0; commit
    ${cli}=             Write    interface ${root_port130}; priority 0;
    Commit Testcase
    Commit Testcase    
   
    

# #######################################
#     #FALCON-118
# ######################################

Enter config mode
    Switch Connection     DUT
    Write    config; system cli prompt2 ${FAL_PROMPT};system cli notifications disable; commit; exit
    Read Until Prompt
    Write     config;
    Read Until Prompt

Initial configuration
    [Documentation]     Admin up interfaces
    FOR    ${port}    IN    @{falcon_Ports}
        Write     interface physical ${port}; breakout to-four;
    END
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
    FOR    ${port}    IN RANGE    1    ${counter}
        Write    interface bundle-${port};mode access;
        Read Until Prompt
    END
    Commit Testcase
    Set Global Variable    ${counter}    1
Check Bundle states
    [Documentation]    Check if bundle is defaulted 
    Write     top;
    # Sleep     20s
    FOR    ${port}    IN RANGE    1    41
        
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
Check States of RSTP falcon side
    Write       top
    FOR    ${port}    IN RANGE    1    40
        Write    do show spanning-tree interface bundle-${port}
        ${cli}=    Read Until Prompt
        Should Not Contain    ${cli}    Yes
    END

    Write     top;
    Read Until Prompt
    Write        do show spanning-tree interface ${root_port} details | include state
    ${cli}=    Read Until Prompt
    Should Contain Any    ${cli}    Forwarding    down    
    FOR    ${port}    IN RANGE    21    39
        Write    do show spanning-tree interface bundle-${port} 
        ${cli}=    Read Until Prompt
        Should Contain Any    ${cli}    Discarding    down
    END  
    FOR    ${port}    IN RANGE    1    20
        
        Write    do show spanning-tree interface bundle-${port} 
        ${cli}=    Read Until Prompt
        Should Contain Any    ${cli}    Forwarding    down
    END
   
########################
#   cleanup
########################
################
#STBR-117 setup
################

Cleanup on DUT1
    Switch Connection     DUT1
    Write     config;
    Read Until Prompt
    Write    top
    Write    bridge default; no spanning-tree-type rstp;
    FOR    ${port}    IN RANGE    1    21
         Write    no interface bundle-${port};
         Read Until Prompt
    END
    Commit Testcase
    Write    top
    FOR    ${port}    IN RANGE    1    21
         Write    no interface bundle ${port};
         Read Until Prompt
    END
    Commit Testcase
    Reset Prompt

################
#STBR-130 setup
################

Cleanup on stbr130
    Switch Connection     stbr130
    Write     config;
    Read Until Prompt
    Write    top
    Write    bridge default; no spanning-tree-type rstp;
    FOR    ${port}    IN RANGE    1    21
         Write    no interface bundle-${port};
         Read Until Prompt
    END
    Commit Testcase
    Write    top;
    FOR    ${port}    IN RANGE    1    21
         Write    no interface bundle ${port};
         Read Until Prompt
    END
    Commit Testcase
    Reset Prompt



########################################
#     FALCON-118
#######################################

Cleanup on DUT
    Switch Connection     DUT
    Write     config;
    Read Until Prompt
    Write    bridge default; no spanning-tree-type rstp;
    FOR    ${port}    IN RANGE    1    40
         Write    no interface bundle-${port};
         Read Until Prompt
    END
    Commit Testcase
    Write    top
    FOR    ${port}    IN RANGE    1    40
         Write    no interface bundle ${port};
         Read Until Prompt
    END
    Commit Testcase
    Reset Prompt