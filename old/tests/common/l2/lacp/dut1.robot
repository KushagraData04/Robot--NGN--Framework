*** Settings ***
Documentation       Test case to set up lacp
Default Tags        layer2  dut1
Variables           data/dut1.yaml
Resource            resource/common.resource
Suite Setup         Connect to device

*** Test Cases ***

Initial configuration
    Enter Config Mode
    [Documentation]     Admin up interfaces
    FOR    ${port}    IN    @{physical}
        ${cli}=             Cli    interface physical ${port}; link-speed auto; admin-status up;
    END
    Commit Testcase
    
Create bundle of the 3 interfaces
    [Documentation]    Create bundle ${bundleid} interface with supplied members 
    ${cli}=             Cli    top;
    ${cli}=             Cli    interface bundle ${bundleid} 
    FOR    ${port}    IN    @{ports}
        ${cli}=             Cli    port ${port};
    END
    ${cli}=             Cli    mode 802.3ad;lacp rate fast; admin-status up;
    Commit Testcase
    Sleep       5s
    
Check bundle state
    [Documentation]    Check bundle ${bundleid} state
    ${cli}=             Cli    top;
    ${cli}=             Cli    do show bundle interface bundle-${bundleid}
