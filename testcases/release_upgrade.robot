*** Settings ***
Name               Release Upgrade
Documentation      Upgrade release on falcon 
Default Tags       release_upgrade
Library            SSHLibrary
Variables          data/l2_suite.yaml
Resource           resource/common.resource
Suite Teardown     Close All Connections


*** Test Cases ***
Update release with given build number
    Skip    By default skipped in git repo, change locally and use.
    Switch Connection     DUT
    Write    exit;
    Write    release-upgrade build-id ${build-id} vrf mgmt-vrf 
    Read Until    Continue? [y|n]
    Write    y
    Read Until    Choice?
    Write    ${choice}
    Read Until Prompt
    Write    reboot
    Read Until    Do you really want to reboot the system? [yes,NO] 
    Write    yes