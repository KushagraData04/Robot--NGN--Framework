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

Configure Mirroring Session
    Enter Config Mode
    [Documentation]     Add the server side port to bridge and clear mac learnt
    # Configure the bridge with two ports
    ${cli}=             Cli    mirroring session ${Name} type erspan-source admin-status up mirror-destination ip ${Dip}
    ${cli}=             Cli    mirror-source interface ${iface} direction ${direction};origin ip ${Sip}
    Commit Testcase
    Check Mirror Session Oper status
    Sleep    5s
#    Checking route 


Admin Down Interface
    Enter Config Mode
    [Documentation]    admin down server port and then up after 20s 
    # Configure the bridge with two ports
    ${cli}=             Cli   top; interface ${iface1}; admin-status down; commit
    Commit Testcase
    Check Mirror Session Oper status
    Sleep    20s 
    ${cli}=             Cli   top; interface ${iface1}; admin-status up; commit
    Commit Testcase
    Check Mirror Session Oper status
#    Checking route




Adding multiple source interfaces and deleting
    Enter Config Mode
    [Documentation]    adding multiple ports in mirroring- source
#    FOR    ${port}    IN    @{physical}
#        ${cli}=             Cli    interface physical ${port}; link-speed auto; admin-status up;
#    END
#    Commit Testcase
    ${cli}=             Cli  mirroring session ${name}; 
    FOR    ${port}    IN    @{interfaces}
        ${cli}=             Cli    mirror-source interface ${port}; admin-status up;
        Commit Testcase
    Sleep  5s
    Check Mirror Session Oper status
    END
 
Deleting spine connectivity for erspan Check
    Enter Config Mode
    [Documentation]    admin down spine port and then up after 20s 
    # Configure the bridge with two ports
    ${cli}=             Cli   top; interface ${spine_bundle}; admin-status down; commit
    Commit Testcase
    Check Mirror Session Oper status
    Checking route
    Sleep    20s 
    ${cli}=             Cli   top; interface ${spine_bundle}; admin-status up; commit
    Commit Testcase
    Check Mirror Session Oper status
#    Checking route 
#

ACL based Mirroring
    Enter Config Mode
    [Documentation]    Set up ACL rule and bind it to mirroring session
    ${cli}=             Cli    mirroring session ${Aclmirror} type erspan-source admin-status up mirror-destination ip ${Dip}
    ${cli}=             Cli    direction ${direction};origin ip ${Origin}
    Commit Testcase
    ${cli}=             Cli    top;access-lists ipv4 ${aclName}
    ${cli}=             Cli    10 permit ${Aclsip} ${sipmask} any mirror-session-id ${Aclmirror}
    Commit Testcase
    ${cli}=             Cli    top; interface ${iface1}
    ${cli}=             Cli    ipv4 access-group ${aclName} ${direction}
    Commit Testcase
    Sleep    5s
    Check Mirror Session Oper status
    Checking route
    
    ${cli}=             Cli    no system cli prompt2
    Commit Testcase
