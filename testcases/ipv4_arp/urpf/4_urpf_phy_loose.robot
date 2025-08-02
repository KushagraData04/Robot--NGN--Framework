*** Settings ***
Documentation       Configurations for lxc
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Library             OperatingSystem
# Variables           ../../data/ipv4.yaml
Variables           ../../../data/ipv4_route.yaml
Resource            ../../../resource/common.resource
Resource            ../../../testcases/ipv4robot/ip_route.resource


*** Test Cases ***
###############
#physical setup
###############

Disable of URPF on DUT2
   [Documentation]    Disable URPF on DUT2
      Switch Connection    ${DUT2.hostname}
       FOR    ${phy}    IN    @{DUT1.phy_interfaces}
         ${cli}=  Write  interface physical ${phy.number} ; ipv4 rpf disabled
       END
      Commit Testcase

   Write    top;

Enable loose URPF on DUT2
    [Documentation]    Enable loose URPF on DUT2
      Switch Connection    ${DUT2.hostname}
      Write  interface physical 1/12/1
      Write    ipv4 rpf loose
      Commit Testcase

   Write    top;

Ping Test2
   Open Connection    ${Server}    alias=${Server158.hostname}    prompt=${DUT_PROMPT3}    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
   Login    ngn    ngn@8737
   Switch Connection    ${Server158.hostname}

   Write  sudo timeout ${3*${Pcounter}} sudo ip netns exec ns-pega-229 tcpdump -i eno12409np1 -nle src 40.40.40.228 and dst 20.20.20.158 -c ${Pcounter} > /tmp/urpf240.txt 2>&1
   Sleep  2s
   Write  ngn@8737


   Open Connection    ${DUT_IP1}    alias=${DUT1.hostname}    prompt=${DUT_PROMPT}      timeout=${DUT_TIMEOUT}     port=${DUT1.ssh_port}
   Login    ${DUT_USERNAME1}    ${DUT_PASSWORD1}
   Switch Connection  ${DUT1.hostname}
   Write    ping -I 40.40.40.228 20.20.20.158 -c ${Pcounter}
   Sleep    ${3*${Pcounter}}s
    
   # Open Connection    ${Server}    alias=${Server158.hostname}    prompt=${DUT_PROMPT3}    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
   # Login    ngn    ngn@8737
   Switch Connection    ${Server158.hostname}
   Read Until Prompt
   Sleep  10s
   # Read the captured output file
   Write    ngn@8737
   Read Until Prompt
   Write    cat /tmp/urpf240.txt 
   ${output}=  Read Until Prompt
   Log    ${output}
   Should Contain    ${output}   ${Pcounter} packets captured
   Should Contain    ${output}   ICMP echo request

Delete Route Configuration on DUT2
   Switch Connection    ${DUT2.hostname}
   Delete2 Route of urpf on DUT2
