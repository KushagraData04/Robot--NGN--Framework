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


*** Variables ***
${start_vlan}    2000
${count}    200
${tmp}    1

*** Test Cases ***
Simulate multiple neighbors via server
    Skip

    Run Keyword If    ${bvi_total_subif} > 250    Skip    Testcase doen not support more than 250 bvi
    Switch Connection     R5

    Write    top; bridge default;
    ${end}=    Evaluate    ${start_vlan} + ${count}
    # ${end_range}=    Evaluate    ${bvi_start_range} + ${bvi_total_subif}
    # Write    allowed-vlan add ${bvi_start_range}-${end_range}
    Write    allowed-vlan add ${start_vlan}-${end}
    Write    interface ${serverport1}; mode trunk; trunk allowed vlan add ${start_vlan}-${end}
   
    # Create bvi on interface based on "total_subif" and assign ip
    FOR  ${session}    IN RANGE   ${start_vlan}    ${end}
        ${tmp}=    Evaluate     ${session}-1999
        Write    top; bridge default;
        Write    vlan ${session}; irb enable;top;
        Write    interface subif bvi-1.${session}; admin-status up;
        Write    ipv4 address 10.67.${tmp}.1 prefix 24;
        Run Keyword If    ${session} % 100 == 0    Commit Testcase
    END
    Commit Testcase

    # Switch Connection    DUT_shell
    # # allow creating neighbor based on GARP messages (by default disabled)
    # Write    echo 1 > /proc/sys/net/ipv4/conf/all/arp_accept
    # Write    echo ${bvi_linux_nh} > /proc/sys/net/ipv4/neigh/default/gc_thresh2
    # Write    echo ${bvi_linux_nh} > /proc/sys/net/ipv4/neigh/default/gc_thresh3

    # FOR  ${session}    IN RANGE   2    ${bvi_total_subif}
    #     Write    echo 20 > /proc/sys/net/ipv4/neigh/bvi-1.${session}/mcast_solicit
    #     Read Until Prompt
    #     Write    echo 20 > /proc/sys/net/ipv4/neigh/bvi-1.${session}/ucast_solicit
    #     Read Until Prompt
    #     Write    echo 5000 > /proc/sys/net/ipv4/neigh/bvi-1.${session}/retrans_time_ms
    #     Read Until Prompt
    #     Write    echo 1 > /proc/sys/net/ipv4/conf/bvi-1.${session}/arp_accept
    #     Read Until Prompt
    # END
    # Sleep    5s
    # Close Connection
    # ${HOME}=    Get Environment Variable    HOME
    # ${ID_RSA_PATH}=    Set Variable    ${HOME}/.ssh/id_rsa
    # Open Connection    ${DUT_IP}    alias=DUT_shell    prompt=${DUT_SHELL_PROMPT}      timeout=${DUT_SHELL_TIMEOUT}
    # Login With Public Key    ${DUT_SHELL_USERNAME}    ${ID_RSA_PATH}

    Switch Connection    SERVER
    FOR  ${session}    IN RANGE   ${start_vlan}    ${end}
        ${tmp}=    Evaluate     ${session}-1999
        # create multiple subifs at the server end based on i/p i.e VLAN      IP/Prefix    gateway ip     server_interface 
        Write    sudo ${scripts_base_dir}/script/phy_subif_create.sh ${session} 10.67.${tmp}.2/${bvi_prefix} 10.67.${tmp}.1 ${server_iface1}
        ${cli}=     Read Until Prompt
        Should Contain     ${cli}     sent
    END
    Sleep    5s

    Write    sudo su
    Read Until       ${SERVER_USERNAME}#
 
    # increase linux buffer size 
    Write    sudo sysctl -w net.core.rmem_max=16777216
    Write    sudo sysctl -w net.core.wmem_max=16777216
    # enable device creation based on GARP
    Write    echo 1 > /proc/sys/net/ipv4/conf/all/arp_notify

    FOR  ${session}    IN RANGE   ${start_vlan}    ${end}
        Read Until    ${SERVER_USERNAME}#
        Write    echo 1 > /proc/sys/net/ipv4/conf/${server_iface1}.${session}/arp_notify
    END
    Read Until    ${SERVER_USERNAME}#
    Sleep    5s
    Write    exit
    Read Until Prompt
    FOR  ${session}    IN RANGE   ${start_vlan}    ${end}
        ${tmp}=    Evaluate     ${session}-1999
        # Create multiple hosts on the subif at server end script parameter   VLAN    IP 3 octet   prefix  hosts/vlan    and server interface
        Write    sudo ${scripts_base_dir}/script/phy_subif_addip.sh ${session} 10.67.${tmp} ${bvi_prefix} ${bvi_ip_per_vlan} ${server_iface1}
        ${cli}=     Read Until Prompt
        Should Contain     ${cli}     done
        Sleep    1s
    END

    Switch Connection    R5
    # check routes programmed in cli
    Write    do show ipv4 fib summary total-routes-configured 
    ${output}=     Read Until Prompt
    #Should Contain    ${output}    ${max_IPv4-Routes}
    
    # Run Keyword If    ${testing_on_hw}    Check ldbg routes

*** Keywords ***
Cleanup
    # Switch Connection    R5
    # ${end}=    Evaluate    ${start_vlan} + ${count}
    # Write    top; bridge default;
    # ${end_range}=    Evaluate    ${bvi_start_range} + ${bvi_total_subif}
    # # Create bvi on interface based on "total_subif" and assign ip
    # FOR  ${session}    IN RANGE   ${start_vlan}    ${end}
    #     Write    top; bridge default;
    #     Write    no vlan ${session};
    #     Run Keyword If    ${session} % 100 == 0    Commit Testcase
    # END
    # Commit Testcase
    
    Switch Connection    SERVER
    ${end}=    Evaluate    ${start_vlan} + ${count}
    FOR  ${session}    IN RANGE   ${start_vlan}    ${end}
        # script to clean devices created at server end
        Write    sudo ${scripts_base_dir}/script/phy_subif_del.sh ${session} ${server_iface1}
        ${cli}=     Read Until Prompt
        Should Contain     ${cli}     done
    END

 