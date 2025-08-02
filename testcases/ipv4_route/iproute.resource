*** Settings ***
Documentation       Configurations for BVI Interfaces IP Testing
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Variables           ../../data/ipv4_route.yaml
Resource            ../../resource/common.resource


*** Keywords ***
Configure Route on DUT1
    [Documentation]    Configures static route on DUT1.
    ${cli} =     Write   router static 20.20.20.158/32 next-hop 30.30.30.229
    Commit Testcase

Delete Route on DUT1
    [Documentation]    Deletes static route on DUT1.
    ${cli} =     Write    no router static 20.20.20.158/32 next-hop 30.30.30.229
    Commit Testcase

Configure Route on DUT2
    [Documentation]    Configures static route on DUT2.
    ${cli} =   Write    router static 10.10.10.158/32 next-hop 30.30.30.228
    Commit Testcase

Delete Route on DUT2
    [Documentation]    Deletes static route on DUT2.
    ${cli} =     Write    no router static 10.10.10.158/32 next-hop 30.30.30.228
    Commit Testcase
    
Configure Routes on Server158
    [Documentation]    Configures static routes on Server158.
    Write    sudo ip netns exec ns-pega-228 ip r add default via 10.10.10.228
    Read Until Prompt
    
    Write    sudo ip netns exec ns-pega-229 ip r add default via 20.20.20.229
    Read Until Prompt

Delete Routes on Server158
    [Documentation]    Deletes static routes on Server158.
    Execute Command    sudo ip netns exec ns-pega-228 ip route del default via 10.10.10.228
    Read Until Prompt

    Execute Command    sudo ip netns exec ns-pega-229 ip route del default via 20.20.20.229
    Read Until Prompt
