*** Settings ***
Name                802.1x
Documentation       802.1x functionality Commands
Default Tags        spt lxc
Library             SSHLibrary
Variables           ../data/dot1x.yaml
Resource            ../resource/stp_issue.resource


*** Variables ***
${LXC_IP}     10.0.3.88
${LXC_PROMPT}     router#
${LXC_TIMEOUT}    30s
${LXC_USERNAME}     rootsystem
${LXC_PASSWORD}     Root@123



${SYS_IP}     192.168.173.182
${SYS_PROMPT}     cdot@cdot-TravelMate-P214-54:~$
${SYS_TIMEOUT}    30s
${SYS_USERNAME}     cdot
${SYS_PASSWORD}     Cdot@1984

${filepath}    /tmp/stp_issue.txt
${cli_phy}    1/1/1
${port}    phy-1_1_1
${hw_port}        0
${if_index}    1

${bundle_id}    2



*** Test Cases ***
Open all connections
    
    # open connections DUT1 
    Open Connection    ${LXC_IP}    alias=lxc    prompt=${LXC_PROMPT}      timeout=${LXC_TIMEOUT}
    Login    ${LXC_USERNAME}    ${LXC_PASSWORD}
    Write    config; system cli prompt2 ${LXC_PROMPT};system cli notifications disable; commit; exit
    Read Until Prompt
    Write     config;
    Read Until Prompt

    Open Connection    ${SYS_IP}    alias=laptop    prompt=${SYS_PROMPT}      timeout=${SYS_TIMEOUT}
    Login    ${SYS_USERNAME}    ${SYS_PASSWORD}
    Write    cd lxcfolder/stp_issue/stbr/
    Read Until    cdot@cdot-TravelMate-P214-54:~/lxcfolder/stp_issue/stbr$
    Write    lxc s stbr   
    Read Until    [sudo] password for cdot:
    Write    ${SYS_PASSWORD}
    Read Until    cdot@cdot-TravelMate-P214-54:~/lxcfolder/stp_issue/stbr$ 
    Write    lxc a stbr 
    Read Until    bash-4.4#
    Write    source /etc/profile
    Read Until    root@router:/#
    Write    lua
    Read Until    Console#  

    # Open Connection    ${SYS_IP}    alias=ldbg    prompt=${SYS_PROMPT}      timeout=${SYS_TIMEOUT}
    # Login    ${SYS_USERNAME}    ${SYS_PASSWORD}
    # Write    cd lxcfolder/stp_issue/fal2/
    # Read Until    cdot@cdot-TravelMate-P214-54:~/lxcfolder/stp_issue/fal2$
    # Write    lxc s fal2   
    # Read Until    [sudo] password for cdot:
    # Write    ${SYS_PASSWORD}
    # Read Until    cdot@cdot-TravelMate-P214-54:~/lxcfolder/stp_issue/fal2$ 
    # Write    lxc a fal2 
    # Read Until    root@CTX-3000:/#
    # Write    ldbg
    # Read Until    LDPM_DEBUG $     

All Permutation check
    Skip
    Create File    path=${filepath}    content=STP issue status\n
    Switch Connection    lxc
    make interface    ${cli_phy}
    # Switch Connection    ldbg
    # Sleep    3s
    # Write    iface 33 simulate-linkup
    Append To File    path=${filepath}    content=Checking status on lua after creating interface(Expected CPSS_STP_DISABLED_E)\n
    lua state check stbr    ${filepath}  ${hw_port} 
    Sleep    5s
    Add to bridge    ${port}
    Append To File    path=${filepath}    content=Checking status on lua after adding it to bridge (Expected CPSS_STP_DISABLED_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Turn on stp
    Sleep    5s
    Append To File    path=${filepath}    content=Checking status on lua after turning on stp(Expected CPSS_STP_BLCK_LSTN_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Sleep    20s
    Append To File    path=${filepath}    content=Checking status on lua 15s after stp(Expected CPSS_STP_LRN_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Sleep    20s
    Append To File    path=${filepath}    content=Checking status on lua turning off stp(Expected CPSS_STP_FRWRD_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Turn off stp
    Sleep    5s
    Append To File    path=${filepath}    content=Checking status on lua turning off stp(Expected CPSS_STP_DISABLED_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Sleep    5s
    Remove from bridge    ${port}
    Append To File    path=${filepath}    content=Checking status on lua removing interface from bridge(Expected CPSS_STP_DISABLED_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Sleep    5s
    # Delete interface    ${cli_phy}

    Add to bridge    ${port}
    Append To File    path=${filepath}    content=Checking status on lua after adding it to bridge (Expected CPSS_STP_DISABLED_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Turn on stp
    Sleep    20s
    Append To File    path=${filepath}    content=Checking status on lua after turning on stp(Expected CPSS_STP_BLCK_LSTN_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Turn off stp
    Sleep    5s
    Append To File    path=${filepath}    content=Checking status on lua turning off stp(Expected CPSS_STP_DISABLED_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Turn on stp
    Sleep    20s
    Append To File    path=${filepath}    content=Checking status on lua after turning on stp(Expected CPSS_STP_BLCK_LSTN_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Remove from bridge    ${port}
    Sleep    5s
    Append To File    path=${filepath}    content=Checking status on lua removing interface from bridge(Expected CPSS_STP_DISABLED_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Add to bridge    ${port}
    Sleep    10s
    Append To File    path=${filepath}    content=Checking status on lua Adding interface back bridge(Expected CPSS_STP_BLCK_LSTN_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Remove from bridge and delete interface    ${port}    ${cli_phy}
    Append To File    path=${filepath}    content=Checking status on lua removing interface back bridge and deleting interface(Expected CPSS_STP_DISABLED_E)\n
    lua state check stbr    ${filepath}  ${hw_port}

Testing on bundle

    Set Global Variable    ${port}       phy-1_1_3
    Set Global Variable    ${hw_port}    2
    Set Global Variable    ${if_index}   3
    Set Global Variable    ${cli_phy}    1/1/3
    Switch Connection    lxc
    Append To File    path=${filepath}    content=Testing on bundle with bundle ${bundle_id} with interface ${port} with if index ${if_index} and hw port ${hw_port}
    make interface    ${cli_phy}
    make bundle    ${bundle_id}    ${port}
    Append To File    path=${filepath}    content=Checking status on lua after creating bundle(Expected CPSS_STP_DISABLED_E)\n
    lua state check stbr    ${filepath}  ${hw_port} 
    Sleep    5s
    Add bundle to bridge    ${bundle_id}
    Append To File    path=${filepath}    content=Checking status on lua after adding bundle to bridge (Expected CPSS_STP_DISABLED_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Turn on stp
    Sleep    5s
    Append To File    path=${filepath}    content=Checking status on lua after turning on stp(Expected CPSS_STP_BLCK_LSTN_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Sleep    20s
    Append To File    path=${filepath}    content=Checking status on lua 15s after stp(Expected CPSS_STP_LRN_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Sleep    20s
    Append To File    path=${filepath}    content=Checking status on lua turning off stp(Expected CPSS_STP_FRWRD_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Turn off stp
    Sleep    5s
    Append To File    path=${filepath}    content=Checking status on lua turning off stp(Expected CPSS_STP_DISABLED_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Sleep    5s
    Remove bundle from bridge    ${bundle_id}
    Append To File    path=${filepath}    content=Checking status on lua removing interface from bridge(Expected CPSS_STP_DISABLED_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Sleep    5s
    
    Add bundle to bridge    ${bundle_id}
    Append To File    path=${filepath}    content=Checking status on lua after adding it to bridge (Expected CPSS_STP_DISABLED_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Turn on stp
    Sleep    20s
    Append To File    path=${filepath}    content=Checking status on lua after turning on stp(Expected CPSS_STP_BLCK_LSTN_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Turn off stp
    Sleep    5s
    Append To File    path=${filepath}    content=Checking status on lua turning off stp(Expected CPSS_STP_DISABLED_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Turn on stp
    Sleep    20s
    Append To File    path=${filepath}    content=Checking status on lua after turning on stp(Expected CPSS_STP_BLCK_LSTN_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Remove bundle from bridge    ${bundle_id}
    Sleep    5s
    Append To File    path=${filepath}    content=Checking status on lua removing bundle from bridge(Expected CPSS_STP_DISABLED_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Add bundle to bridge    ${bundle_id}
    Sleep    10s
    Append To File    path=${filepath}    content=Checking status on lua Adding interface back bridge(Expected CPSS_STP_BLCK_LSTN_E)\n
    lua state check stbr    ${filepath}  ${hw_port}
    Remove bundle from bridge and delete    ${bundle_id}    
    Sleep    2s
    Append To File    path=${filepath}    content=Checking status on lua removing bundle back bridge and deleting bundle(Expected CPSS_STP_DISABLED_E)\n
    lua state check stbr    ${filepath}  ${hw_port}






    
