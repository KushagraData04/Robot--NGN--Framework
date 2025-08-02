*** Settings ***
Documentation       Test case to set up lacp
Library             NetmikoLibrary
Library             Process
Library             OperatingSystem
Variables           data/dut1.yaml
Resource            resource/common.resource
Suite Setup         Connect to device



*** Test Cases ***
Cleanup dut1
    [Documentation]     cleanup dut 1
    ${cli}=             Cli    config; no interface bundle ${bundleid};
    Commit Testcase
    ${cli}=             Cli    no system cli prompt2;
            
