*** Settings ***
Name                MSTI Scale
Documentation       Check msti that can be created in system
Default Tags        monit
Library             SSHLibrary
Variables           data/l2_suite.yaml
Resource            resource/common.resource
Resource            resource/monit.resource
#Suite Teardown      Cleanup

*** Test Cases ***
Create new vlan and check critical processes with monit
    Switch Connection     DUT
    Write    bridge default; spanning-tree-type mstp;
    Write    mstp; mst
    FOR  ${msti}    IN RANGE   1    ${msti_count}
        Write    msti ${msti} vlans ${msti}
        Read Until Prompt
    END
    Commit Testcase
    Switch Connection      DUT_shell
    #Read Until Prompt
    Check Monit Status
    Write    mstpctl showmstilist bvi-1
    ${cli}=    Read Until Prompt
    FOR  ${msti}    IN RANGE   1    ${msti_count}
        ${string_number}=    Convert To String    ${msti}
        Should Contain     ${cli}    ${string_number}
    END
    
*** Keywords ***
Cleanup
    Switch Connection    DUT
    Write    bridge default; no spanning-tree-type mstp;
    Commit Testcase