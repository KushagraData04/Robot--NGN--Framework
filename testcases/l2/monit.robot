*** Settings ***
Name                Monit
Documentation       Sample test to check monit status of critical process after CLI command execution
Default Tags        monit
Library             SSHLibrary
Resource            resource/common.resource
Resource            resource/monit.resource
Suite Teardown      Cleanup

*** Test Cases ***
Create new vlan and check critical processes with monit
    Switch Connection     DUT
    Write     bridge default
    Write     allowed-vlan add 1111
    Write     vlan 1111
    Commit Testcase
    Switch Connection      DUT_shell
    Read Until Prompt
    Check Monit Status

*** Keywords ***
Cleanup
    Switch Connection    DUT
    Write    bridge default; no vlan 1111;
    Commit Testcase