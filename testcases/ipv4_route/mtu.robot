ngn@ngnngn58:~$ sudo ip netns exec ns-pega-228 ping 20.20.20.158 -s 1500
[sudo] password for ngn: 
PING 20.20.20.158 (20.20.20.158) 1500(1528) bytes of data.

--- 20.20.20.158 ping statistics ---
7 packets transmitted, 0 received, 100% packet loss, time 6150ms

CTX-3000#interface physical 1/12/1 ; mtu-profile 3          
CTX-3000#exit
CTX-3000#commit  
[INFO]: Updating MTU profile can cause in-band connections via 'phy-1_12_1' to flap
Commit complete.

ngn@ngnngn58:~$ sudo ip netns exec ns-pega-228 ping 20.20.20.158 -s 9676
PING 20.20.20.158 (20.20.20.158) 9676(9704) bytes of data.

--- 20.20.20.158 ping statistics ---
8 packets transmitted, 0 received, 100% packet loss, time 7160ms

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
Create a MTU profile
    Switch Connection  ${DUT1.hostname}
    Write  mtu-profile ${profile} bytes ${mtu_rate}
    Commit Testcase

Ping Test with same MTU
    Switch Connection  ${Server158.hostname}
    Write    sudo ip netns exec ns-pega-228 ping 20.20.20.158 -c 10 -s 1500 > mtu_ping.txt
    Sleep    1s
    Write    ngn@8737
    Sleep    15s
    Read Until  ${DUT_PROMPT3}

    Open Connection  ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
    Login    ngn    ngn@8737
    Write    cat mtu_ping.txt
    ${cli}   Read Until Prompt
    Should Contain  ${cli}  100% packet loss
    Close Connection

Set the MTU
    Switch Connection  ${DUT1.hostname}
    Write  interface physical ${interface_common} ; mtu-profile ${profile}; exit
    Commit Testcase

    Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
    Login    ngn    ngn@8737

Ping Test with above MTU
    Switch Connection  ${Server158.hostname}
    Write    sudo ip netns exec ns-pega-228 ping 20.20.20.158 -c 10 -c 10 -s 9676 > mtu1_ping.txt
    Sleep    1s
    Write    ngn@8737
    Sleep    15s
    Read Until  ${DUT_PROMPT3}

    Open Connection  ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
    Login    ngn    ngn@8737
    Write    cat mtu1_ping.txt
    ${cli}   Read Until Prompt
    Should Contain  ${cli}  100% packet loss
    Close Connection