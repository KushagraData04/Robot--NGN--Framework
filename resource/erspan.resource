*** Settings ***
Library             Process
Library             OperatingSystem
Library             SSHLibrary
Variables           data/l2_suite.yaml

*** Keywords ***

Erspan send packet from server
    [Arguments]    ${ip}
    Sleep    1s
    Write    sudo python3 ${scripts_base_dir}/send_sip_packet.py ${erspan_packetcount} ${server_iface2} ${ip}.100.100.100
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     sent

Check acl counters for erspan
    [Arguments]    ${rule}
    Write    do show access-lists ipv4 erspan statistics ${dut_iface2} ingress seq-num 1${rule} 
    ${output}=    Read Until Prompt
    Should Contain    ${output}     Hits : ${erspan_pack}

# Counter manipulation  
#     # modified ip address based on the range provided
#     [Arguments]    ${counter}    ${2nd_byte}
#     IF    ${counter} % 250 == 0
#         ${2nd_byte}=     Evaluate    ${2nd_byte} + 1
#         Sleep    1s
#     END
#     ${counter}=     Evaluate    ${counter} % 250
    
#     IF    ${counter} % 250 == 0
#         Set Global Variable    ${counter}    0
#     END
#     RETURN    ${counter}    ${2nd_byte}   
