*** Settings ***
Name               Uidai setup
Documentation      Setup routers AND test TWAP for uidai setup
Default Tags       uidai
Library            SSHLibrary
Library            OperatingSystem
Variables          data/uidai.yaml
Resource           resource/monit.resource
Resource           resource/common.resource
# Suite Teardown     Cleanup

*** Variables ***
${falcon118_ip}    5.5.5.5
${falcon103_ip}    2.2.2.2
${schedule_name}    every1m

*** Test Cases ***

TWAP setup on Falcon DUT
    Switch Connection    R5
    Write    top
    Write    time-range ${schedule_name} periodic every-n-minutes 1
    Commit Testcase
    Write    top
    Write    service sla-server
    Commit Testcase
    Write    top
    Write    ip sla connection 1 local-address ${falcon118_ip} remote-address ${falcon103_ip}
    # Write    trigger-execution
    Commit Testcase
    Switch Connection    R2
    Write    top
    Write    time-range ${schedule_name} periodic every-n-minutes 1
    Commit Testcase
    Write    top
    Write    service sla-server
    Commit Testcase
    Write    top
    Write    ip sla connection 1 local-address ${falcon103_ip} remote-address ${falcon118_ip}
    Commit Testcase
    Write    trigger-execution
    Sleep    20s
    Write    do show ip sla connection 1 
    ${out}=    Read Until Prompt
    Should Contain    ${out}    system initiated
    Switch Connection    R5
    Write    do show ip sla connection 1 
    ${out}=    Read Until Prompt
    Should Contain    ${out}    system initiated

*** Keywords ***
Cleanup
    Switch Connection    R5
    Write    top
    Write    no ip sla connection 1
    Write    no service sla-server
    Commit Testcase
    Switch Connection    R2
    Write    top
    Write    no ip sla connection 1
    Write    no service sla-server
    Commit Testcase

