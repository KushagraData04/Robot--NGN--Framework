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
   # After executing the below command the default route is carried out which is forward
   Write  no router static ${static_ip} next-hop ${def_nh}
   Commit Testcase

Ping Test
   Switch Connection  ${Server158.hostname}
   Write  sudo ip netns exec ns-pega-228 ping 20.20.20.158 -c 10 > f_ping.txt
   Sleep  1s
   Write  ngn@8737
   Sleep  15s
   Read Until  ${DUT_PROMPT3}

   Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
   Login  ngn    ngn@8737
   Write  cat f_ping.txt
   ${cli}   Read Until Prompt
   Should Contain    ${cli}     0% packet loss
   Close Connection

Forward Test
   Open Connection    ${DUT_IP1}    alias=${DUT1.hostname}    prompt=${DUT_PROMPT}      timeout=${DUT_TIMEOUT}     port=${DUT1.ssh_port}
   Login    ${DUT_USERNAME1}    ${DUT_PASSWORD1}
   Switch Connection  ${DUT1.hostname}
   Write  ip r show | grep 20.20.20
   Sleep  1s
   Read Until  20.20.20.158 via 30.30.30.229 dev phy-1_12_1 proto unspec metric 300