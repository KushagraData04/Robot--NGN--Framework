*** Settings ***
Documentation       Test case to cleanup STP on dut1
Library             NetmikoLibrary
Library             Process
Library             OperatingSystem
Variables           data/dut1.yaml
Resource            resource/common.resource
Suite Setup         Connect to device


*** Test Cases ***
Cleanup dut1
    ${cli}=    Cli    config; bridge default; no spanning-tree-type stp;
    FOR    ${port}    IN    @{ports}
        ${cli}=    Cli    no interface ${port};
    END
    Commit Testcase
    ${cli}=             Cli    no system cli prompt2; 
    Commit Testcase

