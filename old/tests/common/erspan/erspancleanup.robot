*** Settings ***
Documentation       Test case to verify Mac Aging timer
Library             NetmikoLibrary
Library             Process
Library             1.py
Library             OperatingSystem
Resource            resource/common.resource
Default Tags        layer2
Variables           data/erspan.yaml
Suite Setup         Connect to device

*** Test Cases ***

Delete Mirroring Session
    Enter Config Mode
    [Documentation]     cleanup mirrioring session 
    # Configure the bridge with two ports
    ${cli}=             Cli    no mirroring session ${Name}
    Commit Testcase
    ${cli}=             Cli    no access-lists ipv4 ${AclName};no mirroring session ${Aclmirror}
    Commit Testcase
    ${cli}=             Cli    no system cli prompt2
    Commit Testcase



