*** Settings ***
Documentation       Configurations for lxc
Library             SSHLibrary
Library             Process
Library             String
Library             Collections
Library             OperatingSystem
Variables           ../../data/ipv4_route.yaml
Resource            ../../resource/common.resource
Resource            ../../testcases/ipv4_route/iproute.resource


*** Test Cases ***
###############
#physical setup
###############
Reconfiguration DUT1
   [Documentation]  Reconfiguration ${DUT1.hostname}
   Switch Connection    ${DUT1.hostname}
   Write  router static ${static_ip} next-hop ${def_nh} action local
   Commit Testcase

Ping Test
   Switch Connection  ${Server158.hostname}
#    Read Until Prompt
   Write    sudo ip netns exec ns-pega-228 ping 20.20.20.158 -c 10 > l_ping.txt
   Sleep    1s
   Write    ngn@8737
   Sleep    15s
   Read Until  ${DUT_PROMPT3}

   Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
   Login    ngn    ngn@8737
   Write    cat l_ping.txt
   ${cli}   Read Until Prompt
   Should Contain    ${cli}     0% packet loss
   Close Connection

Local Test
   Open Connection    ${DUT_IP1}    alias=${DUT1.hostname}    prompt=${DUT_PROMPT}      timeout=${DUT_TIMEOUT}     port=${DUT1.ssh_port}
   Login    ${DUT_USERNAME1}    ${DUT_PASSWORD1}

   Switch Connection  ${DUT1.hostname}
   Write    ip r show table local | grep 20.20.20
   Sleep    1s
   Read Until  local 20.20.20.158 dev lo proto unspec scope host metric 300