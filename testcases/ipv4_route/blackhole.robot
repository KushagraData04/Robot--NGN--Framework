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
   Write  no router static ${static_ip} next-hop ${DUT2.nh}
   Commit Testcase
   Write  router static ${static_ip} next-hop ${def_nh} action discard
   Commit Testcase

Ping Test
   Switch Connection  ${Server158.hostname}
#    Read Until Prompt
   Write    sudo ip netns exec ns-pega-228 ping 20.20.20.158 -c 10 > b_ping.txt
   Sleep    1s
   Write    ngn@8737
   Sleep    15s
   Read Until  ${DUT_PROMPT3}

   Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
   Login    ngn    ngn@8737
   Write    cat b_ping.txt
   ${cli}   Read Until Prompt
   Should Contain    ${cli}     100% packet loss
   Close Connection

# Then run the ping.robot for bringing the connections as it was previously (then go to other test)