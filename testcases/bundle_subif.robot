*** Settings ***
Documentation       Test case to simulate crash on multiple subif creation on bundle in single commit
Default Tags        layer2  dut1
Library             SSHLibrary
Variables           data/bundle_subif.yaml
Variables           data/credentials.yaml
Resource            resource/common.resource
Resource            resource/monit.resource
Suite Teardown      Close All Connections



*** Test Cases ***
Create multiple subif on bundle in single commit and check monit
    [Documentation]    Create multiple subif on bundle in single commit and check monit
    Open Connection    192.168.111.118    alias=falcon118    prompt=${DUT_NAME}#      timeout=180s
    Login    ${USERNAME}    ${PASSWORD}
    Open Connection    192.168.111.118    alias=falcon_shell    prompt=${DUT_NAME}:~#      timeout=30s
    Login With Public Key    ${USERNAME_SHELL}    /home/yp/.ssh/id_rsa

    Switch Connection     falcon118
    Write and wait    config; system cli prompt2 ${DUT_NAME}#; system cli notifications disable; commit; exit
    Write and wait    config

    Switch Connection     falcon118
    FOR    ${port}    IN    @{falcon_Ports}
        Write     interface physical ${port};admin-status up;
        Write     breakout to-four
        Write     lldp transmit
        Write     lldp receive
        Read Until Prompt
    END 
    Commit Testcase
    Write    top;
    Read Until Prompt
    Write     interface physical ${phy};admin-status up;link-speed 10g;
    Commit Testcase

    Switch Connection     falcon118
    Write     interface bundle ${bundle_id}
    Write     mode 802.3ad;lacp rate fast; admin-status up;
    FOR    ${port}    IN    @{falcon_bundle_ports}
        Write    port ${port}
        Read Until Prompt
    END
    Commit Testcase

    Switch Connection     falcon118
    FOR    ${port}    IN RANGE    1   ${subif_count} + 1
        Write    interface subif bundle-${bundle_id}.${port}
        Write    admin-status up
        Write    ipv4 address 1.3.${port}.1 prefix 24
        Read Until Prompt
    END
    Commit Testcase
    Switch Connection    falcon_shell
    Check Monit Status

Delete multiple subif from bundle in single commit
    Switch Connection     falcon118
    [Documentation]     Delete multiple subif from bundle in single commit
    FOR    ${port}    IN RANGE    1   ${subif_count} + 1
        Write    no interface subif bundle-${bundle_id}.${port}
        Read Until Prompt
    END
    Commit Testcase
    Switch Connection    falcon_shell
    Check Monit Status
    Switch Connection    falcon118
    Write     no interface bundle ${bundle_id}
    Commit Testcase
    FOR    ${port}    IN    @{falcon_Ports}
        Write     no interface physical ${port}
        Read Until Prompt
    END 
    Commit Testcase
    Switch Connection    falcon_shell
    Check Monit Status