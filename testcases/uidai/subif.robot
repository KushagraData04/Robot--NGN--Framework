*** Settings ***
Name                Subif
Documentation       Check subif feature
Default Tags        Falcon 118
Library             SSHLibrary
Library             OperatingSystem
Variables           data/l2_suite.yaml
Resource            resource/common.resource
Suite Teardown      Cleanup


*** Test Cases ***
subif testcase
    Switch Connection    R5
    Write    top
    FOR  ${session}    IN RANGE   2    ${bvi_total_subif}
        
        Create Subif    ${dut_iface2}    ${session}    100.100.${session}.1    ${bvi_prefix}   
        Run Keyword If    ${session} % 50 == 0    Commit Testcase
    END
    Commit Testcase
    Switch Connection    DUT_shell
    # allow creating neighbor based on GARP messages (by default disabled)
    Write    echo 1 > /proc/sys/net/ipv4/conf/all/arp_accept
    Write    echo ${bvi_linux_nh} > /proc/sys/net/ipv4/neigh/default/gc_thresh2
    Write    echo ${bvi_linux_nh} > /proc/sys/net/ipv4/neigh/default/gc_thresh3
    Read Until Prompt
    FOR  ${session}    IN RANGE   2    ${bvi_total_subif}
        Write    echo 20 > /proc/sys/net/ipv4/neigh/${dut_iface2}.${session}/mcast_solicit
        Read Until Prompt
        Write    echo 20 > /proc/sys/net/ipv4/neigh/${dut_iface2}.${session}/ucast_solicit
        Read Until Prompt
        Write    echo 5000 > /proc/sys/net/ipv4/neigh/${dut_iface2}.${session}/retrans_time_ms
        Read Until Prompt
        Write    echo 1 > /proc/sys/net/ipv4/conf/${dut_iface2}.${session}/arp_accept
        Read Until Prompt
    END
    Sleep    5s
    Write    cd
    Write    cd

    Switch Connection    SERVER
    
    FOR  ${session}    IN RANGE   2    ${bvi_total_subif}
       
        
        # create multiple subifs at the server end based on i/p i.e VLAN      IP/Prefix    gateway ip     server_interface 
        Write    sudo ${scripts_base_dir}/script/phy_subif_create.sh ${session} 100.100.${session}.2/${bvi_prefix} 100.100.${session}.1 ${server_iface}
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
    FOR  ${session}    IN RANGE   2    ${bvi_total_subif}
        Read Until       ${SERVER_USERNAME}#
        Write    echo 1 > /proc/sys/net/ipv4/conf/${server_iface}.${session}/arp_notify
    END
    Read Until       ${SERVER_USERNAME}#
    Sleep    5s
    Write    exit
    Read Until Prompt
    FOR  ${session}    IN RANGE   2    ${bvi_total_subif}
        Write    sudo ${scripts_base_dir}/script/phy_subif_addip.sh ${session} 100.100.${session} ${bvi_prefix} ${bvi_ip_per_vlan} ${server_iface}
        ${cli}=     Read Until Prompt
        Should Contain     ${cli}     done
        Sleep    1s
    END
    Switch Connection    R5
    # check routes programmed in cli
    Sleep    10s
    Write    do show ipv4 fib summary total-routes-configured 
    ${output}=     Read Until Prompt
    #Should Contain    ${output}    ${max_IPv4-Routes}

    
    # Run Keyword If    ${testing_on_hw}    Check ldbg routes
*** Keywords ***
Cleanup
    Switch Connection    R5
    # clean subif on falcon
    FOR  ${session}    IN RANGE   2    ${bvi_total_subif}
        Write    top; no interface subif ${dut_iface2}.${session} 
    END
    Commit Testcase
    Switch Connection    SERVER
    FOR  ${session}    IN RANGE   2    ${bvi_total_subif}
        ${counter}=     Evaluate    ${session} + ${bvi_start_range}
        # script to clean devices created at server end
        Write    sudo ${scripts_base_dir}/script/phy_subif_del.sh ${session} ${server_iface}
        ${cli}=     Read Until Prompt
        Should Contain     ${cli}     done
    END

