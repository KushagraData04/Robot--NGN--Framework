*** Settings ***
Documentation       Cleanup for all lxc
Library             SSHLibrary
Library             Collections
Library             OperatingSystem
Library             Process
Library             String
Library             pandas
Variables           ../../data/mclag_falcon.yaml
Resource            ../../resource/common.resource

*** Test Cases ***
#############################
#cleanups
#############################

Enter config mode
   Open Connection    ${DUT_IP1}    alias=${peer1.hostname}    prompt=${DUT_PROMPT1}      timeout=${DUT_TIMEOUT}     port=${peer1.ssh_port}
   Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
   Write    config; system cli prompt2 ${DUT_PROMPT1}; system cli notifications disable; commit; exit
   Read Until Prompt
   Write     config;
   Read Until Prompt
   Open Connection    ${DUT_IP2}    alias=${peer2.hostname}    prompt=${DUT_PROMPT2}      timeout=${DUT_TIMEOUT}     port=${peer2.ssh_port}
   Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
   Write    config; system cli prompt2 ${DUT_PROMPT2}; system cli notifications disable; commit; exit
   Read Until Prompt
   Write     config;
   Read Until Prompt
   Open Connection    ${DUT_IP3}    alias=${host1.hostname}    prompt=${DUT_PROMPT3}      timeout=${DUT_TIMEOUT}     port=${host1.ssh_port}
   Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
   Write    config; system cli prompt2 ${DUT_PROMPT3}; system cli notifications disable; commit; exit
   Read Until Prompt
   Write     config;
   Read Until Prompt
   Open Connection    ${DUT_IP4}    alias=${host2.hostname}    prompt=${DUT_PROMPT4}      timeout=${DUT_TIMEOUT}     port=${host2.ssh_port}
   Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
   Write    config; system cli prompt2 ${DUT_PROMPT4}; system cli notifications disable; commit; exit
   Read Until Prompt
   Write     config;
   Read Until Prompt
   Open Connection    ${DUT_IP5}    alias=${hostpa.hostname}   prompt=${DUT_PROMPT5}      timeout=${DUT_TIMEOUT}     port=${hostpa.ssh_port}
   Login    ${DUT_USERNAME}    ${DUT_PASSWORD}
   Write    config; system cli prompt2 ${DUT_PROMPT5}; system cli notifications disable; commit; exit
   Read Until Prompt
   Write     config;
   Read Until Prompt 
   
Cleanups peer1
   [Documentation]     Cleanup steps for lxc1
   Switch Connection    ${peer1.hostname}
   FOR    ${bundle}    IN    @{peer1.bundles}   
   Write     interface bundle ${bundle.number}; no mclag-instance 1
   Commit Testcase
   END
   Write     top
   Write     no bridge default
   Read Until Prompt
   Write     no mclag 1
   Read Until Prompt
   Commit Testcase

   FOR    ${bundle}    IN    @{peer1.bundles}
   Write     no interface bundle ${bundle.number}
   Read Until Prompt
   END
   Commit Testcase

   FOR    ${bundle}    IN    @{peer1.bundles_to_spine1}
   Write     no interface bundle ${bundle.number}
   Read Until Prompt
   END
   Commit Testcase
   
   FOR    ${port}    IN    @{peer1.ports}
   Write     no interface physical ${port.number}
   Read Until Prompt
   END
   Commit Testcase

   FOR    ${lo}    IN    @{peer1.loopback}
   Write     no interface loopback ${lo.number}
   Read Until Prompt
   END

   # Write   top;
   # Write   router ospf1; area 0
   # Write   host 100.100.100.2
   # Write   no track-ufd-group  
   # Commit Testcase
   # Write   host 100.100.100.3
   # Write   no track-ufd-group
   # Commit Testcase
   Write   top
   Write   no ufd group 1
   Commit Testcase 

   Write     top
   Write     no router ospf 1
   Commit Testcase

Cleanups peer2
   [Documentation]     Cleanup steps for lxc2
   Switch Connection    ${peer2.hostname}
   FOR    ${bundle}    IN    @{peer2.bundles}   
   Write     interface bundle ${bundle.number}; no mclag-instance 1
   Commit Testcase
   END
   Write     top
   Write     no bridge default
   Read Until Prompt
   Write     no mclag 1
   Read Until Prompt
   Commit Testcase

   FOR    ${bundle}    IN    @{peer2.bundles}
   Write     no interface bundle ${bundle.number}
   Read Until Prompt
   END
   Commit Testcase

   FOR    ${bundle}    IN    @{peer2.bundles_to_spine2}
   Write     no interface bundle ${bundle.number}
   Read Until Prompt
   END
   Commit Testcase
   
   FOR    ${port}    IN    @{peer2.ports}
   Write     no interface physical ${port.number}
   Read Until Prompt
   END
   Commit Testcase

   FOR    ${lo}    IN    @{peer2.loopback}
   Write     no interface loopback ${lo.number}
   Read Until Prompt
   END

   Write   top
   Write   no ufd group 1
   Commit Testcase

   Write     top
   Write     no router ospf 1
   Commit Testcase

Cleanups host1
   [Documentation]     Cleanup steps for lxc3
   Switch Connection    ${host1.hostname}
   Write     no bridge default; commit
   Write     no interface bundle 23; commit
   FOR    ${port}    IN    @{host1.ports}
   Write     no interface physical ${port.number}
   END
   Commit Testcase

Cleanups host2
   [Documentation]     Cleanup steps for lxc4
   Switch Connection    ${host2.hostname}
   Write     no bridge default; commit
   Write     no interface bundle 45; commit
   FOR    ${port}    IN    @{host2.ports}
   Write     no interface physical ${port.number}
   END
   Commit Testcase

Cleanups hostpa
   [Documentation]     Cleanup steps for lxc5
   Switch Connection    ${hostpa.hostname}
   Write     no bridge default
   Read Until Prompt
   FOR    ${bundle}    IN    @{hostpa.bundles}
   Write     no interface bundle ${bundle.number}
   Read Until Prompt
   END
   Commit Testcase

   FOR    ${port}    IN    @{hostpa.ports}
   Write     no interface physical ${port.number}
   Read Until Prompt
   END
   Commit Testcase

   FOR    ${lo}    IN    @{hostpa.loopback}
   Write     no interface loopback ${lo.number}
   Read Until Prompt
   END

   Write     top
   Write     no router ospf 1
   Commit Testcase