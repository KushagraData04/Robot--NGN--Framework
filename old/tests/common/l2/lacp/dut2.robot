*** Settings ***
Documentation       Test case to set up lacp
Library             NetmikoLibrary
Library             Process
Library             OperatingSystem
Default Tags        layer2, dut2
Resource            resource/common.resource
Variables           data/dut2.yaml
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
    Should Not Contain    ${cli}    defaulted                
   
Delete bundle interface
    [Documentation]     cleanup
    ${cli}=             Cli    top;
    ${cli}=             Cli    no interface bundle ${bundleid}; 
    Commit Testcase
   

