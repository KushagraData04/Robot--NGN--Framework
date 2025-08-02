*** Settings ***
Name               Uidai setup
Documentation      Setup routers for uidai setup
...                Bring phy up and set speed
...                Configure loopback ip
...                Configure OSPF
Default Tags       uidai
Library            SSHLibrary
Library            OperatingSystem
Variables          data/uidai.yaml
Resource           resource/monit.resource
Resource           resource/common.resource
Suite Teardown     Cleanup


*** Test Cases ***

Physical ports creation
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

    Switch Connection    R4
    FOR    ${port}    ${speed}    IN ZIP     ${R4_ports}       ${R4_ports_speed}
        Write     interface physical ${port};
        Write     admin-status up;
        Write     link-speed ${speed}
    END
    Commit Testcase
    Write    top;

    Switch Connection    R5
    FOR    ${port}    IN    @{R5_breakout_ports}
        Write     interface physical ${port};
        Write     breakout to-four;
    END    
    Commit Testcase
    
    Write    top;
    FOR    ${port}    ${speed}    IN ZIP     ${R5_ports}       ${R5_ports_speed}
        Write     interface physical ${port};
        Write     admin-status up;
        Write     link-speed ${speed}
    END
    Commit Testcase
    Write    top;

Loopback interface creation
    Skip
    Switch Connection    R2
    Write    interface loopback 1;
    Write    admin-status up;
    Write    ipv4 address ${R2_Loopback_IP} prefix 32
    Commit Testcase
    Write    top;
    Switch Connection    R3
    Write    interface loopback 1;
    Write    admin-status up;
    Write    ipv4 address ${R3_Loopback_IP} prefix 32
    Commit Testcase
    Write    top;
    Switch Connection    R4
    Write    interface loopback 1;
    Write    admin-status up;
    Write    ipv4 address ${R4_Loopback_IP} prefix 32
    Commit Testcase
    Write    top;
    Switch Connection    R5
    Write    interface loopback 1;
    Write    admin-status up;
    Write    ipv4 address ${R5_Loopback_IP} prefix 32
    Commit Testcase
    Write    top;

*** Keywords ***

Cleanup
    Switch Connection    R2
    Switch Connection    R3
    Switch Connection    R4
    Switch Connection    R5