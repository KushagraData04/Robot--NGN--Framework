*** Settings ***
Documentation       Test case to verify Mac learning on port
Library             NetmikoLibrary
Library             Process
Library             OperatingSystem
Resource            resource/common.resource
Default Tags        layer2
Variables           data/sflow.yaml
Suite Setup         Connect to device

*** Test Cases ***

Add set up sflow
    #[Documentation]     Configure sflow
    # Configure the bridge with two ports
    ${cli}=             Cli    config;sflow enable;
    Commit Testcase
    ${cli}=             Cli    sflow receiver-ip ${receiverip}; sflow agent-ip ${agentip};sflow max-sample-size 1000;
    Commit Testcase
    ${cli}=             Cli    top; interface physical ${port};
    ${cli}=             Cli    sflow flow-sampler-mode enable
    Commit Testcase


