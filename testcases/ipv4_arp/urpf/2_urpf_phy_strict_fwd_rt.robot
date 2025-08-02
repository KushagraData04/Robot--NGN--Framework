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

Test Route Configuration on DUT2
   Switch Connection    ${DUT2.hostname}
   Configure1 Route of urpf on DUT2

Ping Test
   Open Connection    ${Server}    alias=${Server158.hostname}    prompt=${DUT_PROMPT3}    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
   Login    ngn    ngn@8737
   Switch Connection    ${Server158.hostname}

   Write  timeout ${3*${Pcounter}} sudo ip netns exec ns-pega-229 tcpdump -i eno12409np1 -nle src 40.40.40.228 and dst 20.20.20.158 -c ${Pcounter} > /tmp/urpf240.txt 2>&1
   Sleep  2s
   Write  ngn@8737


   Open Connection    ${DUT_IP1}    alias=${DUT1.hostname}    prompt=${DUT_PROMPT}      timeout=${DUT_TIMEOUT}     port=${DUT1.ssh_port}
   Login    ${DUT_USERNAME1}    ${DUT_PASSWORD1}
   Switch Connection  ${DUT1.hostname}
   Write    ping -I 40.40.40.228 20.20.20.158 -c ${Pcounter}
   Sleep    ${3*${Pcounter}}s
   Close Connection
    

   Switch Connection    ${Server158.hostname}
   Read Until Prompt
   Sleep  10s
   # Read the captured output file
   Write    ngn@8737
   Read Until Prompt
   Write    cat /tmp/urpf240.txt
   ${output}=  Read Until Prompt
   Log    ${output}
   Should Contain    ${output}  ${Pcounter} packets captured  

   # Check if file is empty (strict RPF) or contains packet exchange (loose/disabled)
   Run Keyword If    '0 packets dropped by kernel' in """${output}""" and '${Pcounter} packets captured' in """${output}""" 
   ...    Log    RPF mode is STRICT

   Run Keyword If    'ICMP echo request' in """${output}""" and 'ICMP echo reply' in """${output}"""
   ...    Log    RPF mode is LOOSE or DISABLED

   Run Keyword If    'LLDP' in """${output}"""    
   ...    Log    LLDP Packet Detected - Likely No ICMP Response Captured


Delete Route Configuration on DUT2
   Switch Connection    ${DUT2.hostname}
   Delete1 Route of urpf on DUT2
