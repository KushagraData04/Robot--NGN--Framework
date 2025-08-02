*** Settings ***
Name               Uidai setup
Documentation      Setup routers for uidai setup
...                Configure OSPF
Default Tags       uidai
Library            SSHLibrary
Library            OperatingSystem
Variables          data/uidai.yaml
Resource           resource/monit.resource
Resource           resource/common.resource
Suite Teardown     Cleanup


*** Test Cases ***

Physical interface ipv4 configuration
    # Switch Connection    R2
    # FOR    ${port}    ${ip}    IN ZIP     ${R2_ports}       ${R2_phy_ports_ip}      
    #     IF  '${ip}' != 'None'
    #         Write     interface physical ${port};
    #         Write     ipv4 address ${ip} prefix 24  
    #     END
    # END
    # Commit Testcase
    # Write    top;

    Switch Connection    R3
    FOR    ${port}    ${ip}    IN ZIP     ${R3_ports}       ${R3_phy_ports_ip}      
        IF  '${ip}' != 'None'
            Write     interface physical ${port};
            Write     ipv4 address ${ip} prefix 24  
        END
    END
    Commit Testcase
    Write    top;

    # Switch Connection    R4
    # FOR    ${port}    ${ip}    IN ZIP     ${R4_ports}       ${R4_phy_ports_ip}      
    #     IF  '${ip}' != 'None'
    #         Write     interface physical ${port};
    #         Write     ipv4 address ${ip} prefix 24  
    #     END
    # END
    # Commit Testcase
    # Write    top;

    Switch Connection    R5
    FOR    ${port}    ${ip}    IN ZIP     ${R5_ports}       ${R5_phy_ports_ip}      
        IF  '${ip}' != 'None'
            Write     interface physical ${port};
            Write     ipv4 address ${ip} prefix 24  
        END
    END
    Commit Testcase
    Write    top;

OSPF configuration
    # Switch Connection    R2
    # Write    router ospf 1 router-id ${R2_Loopback_IP} administrative-status up
    # Write    trap-support enable
    # Write    area 0
    # FOR    ${ip}    IN    @{R2_phy_ports_ip}
    #     IF  '${ip}' != 'None'
    #         Write    network ${ip} authentication none
    #         Write    administrative-status up
    #         Write    exit
    #     END
    # END
    # Write    host ${R2_Loopback_IP} administrative-status up
    # Commit Testcase
    # Write    top;

    Switch Connection    R3
    Write    router ospf 1 router-id ${R3_Loopback_IP} administrative-status up
    Write    trap-support enable
    Write    area 0
    FOR    ${ip}    IN    @{R3_phy_ports_ip}
        IF  '${ip}' != 'None'
            Write    network ${ip} authentication none
            Write    administrative-status up
            Write    exit
        END
    END
    Write    host ${R3_Loopback_IP} administrative-status up
    Commit Testcase
    Write    top;

    # Switch Connection    R4
    # Write    router ospf 1 router-id ${R4_Loopback_IP} administrative-status up
    # Write    trap-support enable
    # Write    area 0
    # FOR    ${ip}    IN    @{R4_phy_ports_ip}
    #     IF  '${ip}' != 'None'
    #         Write    network ${ip} authentication none
    #         Write    administrative-status up
    #         Write    exit
    #     END
    # END
    # Write    host ${R4_Loopback_IP} administrative-status up
    # Commit Testcase
    # Write    top;

    Switch Connection    R5
    Write    router ospf 1 router-id ${R5_Loopback_IP} administrative-status up
    Write    trap-support enable
    Write    area 0
    FOR    ${ip}    IN    @{R5_phy_ports_ip}
        IF  '${ip}' != 'None'
            Write    network ${ip} authentication none
            Write    administrative-status up
            Write    exit
        END
    END
    Write    host ${R5_Loopback_IP} administrative-status up
    Commit Testcase
    Write    top;
*** Keywords ***

Cleanup
    Switch Connection    R2
    Switch Connection    R3
    Switch Connection    R4
    Switch Connection    R5