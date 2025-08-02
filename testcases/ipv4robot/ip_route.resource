*** Settings ***
Documentation       Configurations for BVI Interfaces IP Testing
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Variables           ../../data/ipv4.yaml
Resource            ../../resource/common.resource


*** Keywords ***
Configure1 Route of urpf on DUT2
    [Documentation]    Configures static route on DUT2.
    ${cli} =     Write   router static 40.40.40.0/24 next-hop 30.30.30.228
    Commit Testcase

Delete1 Route of urpf on DUT2
    [Documentation]    Deletes static route on DUT2.
    ${cli} =     Write    no router static 40.40.40.0/24 next-hop 30.30.30.228
    Commit Testcase

Configure2 Route of urpf on DUT2
    [Documentation]    Configures 2nd static route on DUT2.
    ${cli} =     Write    router static 40.40.40.0/24 next-hop 11.11.11.1
    Commit Testcase

Delete2 Route of urpf on DUT2
    [Documentation]    Deletes 2nd static route on DUT2.
    ${cli} =     Write    no router static 40.40.40.0/24 next-hop 11.11.11.1
    Commit Testcase

Configure Route on DUT1
    [Documentation]    Configures static route on DUT1.
    ${cli} =     Write   router static 20.20.20.158/32 next-hop 30.30.30.229
    Commit Testcase
    # Configure IPv6 Route on DUT1 (228)
    # Write    router static 229:20::158/128 next-hop 30:30::229
    # Commit Testcase

Delete Route on DUT1
    [Documentation]    Deletes static route on DUT1.
    ${cli} =     Write    no router static 20.20.20.158/32 next-hop 30.30.30.229
    Commit Testcase

Configure Route on DUT2
    [Documentation]    Configures static route on DUT2.
    ${cli} =   Write    router static 10.10.10.158/32 next-hop 30.30.30.228
    Commit Testcase
    # Configure IPv6 Route on DUT2 (229)
    Write    router static 228:10::158/128 next-hop 30:30::228
    Commit Testcase

Delete Route on DUT2
    [Documentation]    Deletes static route on DUT2.
    ${cli} =     Write    no router static 10.10.10.158/32 next-hop 30.30.30.228
    Commit Testcase
    
Configure Routes on Server158
    [Documentation]    Configures static routes on Server158.
    Write    sudo ip netns exec ns-pega-228 ip r add default via 10.10.10.228
    # Read Until Prompt
    # For IPv6
    Write  sudo ip netns exec ns-pega-228 ip -6 r del default via 228:10::228
    Write  sudo ip netns exec ns-pega-228 ip -6 route add default via 228:10::228 
    # Read Until Prompt
    
    Write    sudo ip netns exec ns-pega-229 ip r add default via 20.20.20.229
    # Read Until Prompt
    # For IPv6
    Write  sudo ip netns exec ns-pega-229 ip -6 r del default via 229:20::229
    Write  sudo ip netns exec ns-pega-229 ip -6 route add default via 229:20::229 
    # Read Until Prompt

Delete Routes on Server158
    [Documentation]    Deletes static routes on Server158.
    Execute Command    sudo ip netns exec ns-pega-228 ip route del default via 10.10.10.228
    Read Until Prompt

    Execute Command    sudo ip netns exec ns-pega-229 ip route del default via 20.20.20.229
    Read Until Prompt