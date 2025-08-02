*** Settings ***
Name                Voice Vlan
Documentation       Check Voice Vlan feature
Default Tags        Falcon 118
Library             SSHLibrary
Library             OperatingSystem
Variables           data/l2_suite.yaml
Resource            resource/common.resource
# Suite Teardown      Cleanup

*** Variables ***
${voice_vlan}    401
${file_name}    /tmp/voice_vlan.txt
${mode}         oui
${classmap_name}    test-phone
${smac}          02:12:12:00:00:00
${mac_mask}      ff:ff:ff:00:00:00   
${phy}           1/18/4
${policy_name}    vvlan401
${no_of_packet}    100 
${src_mac}        02:12:12:55:55:55

*** Test Cases ***
Set a mac limit on interface and check followed by cleanup

    Create File  path=${file_name}  content=Voice Vlan testing\n
    # Sleep    ${sleep_duration}
    Switch Connection    R5
    Write    bridge default; allowed-vlan add ${limit_vlan},${voice_vlan} ; vlan ${voice_vlan};
    Commit Testcase
    Write      exit;interface ${serverport1};mode trunk; trunk allowed vlan add ${limit_vlan},${voice_vlan};
    Write      exit;interface ${dut_iface2};mode access; access vlan ${limit_vlan};
    Write     voice vlan ${voice_vlan} mode ${mode}
    Commit Testcase 
    Write    top
    Write    qos classmap match-any ${classmap_name} match src-mac ${smac} src-mac-mask ${mac_mask}
    Commit Testcase
    Write    top;qos policymap ${policy_name}; class ${classmap_name} set-vlan ${voice_vlan} set-cos 4; set-queue 5;
    Commit Testcase
    Write    top
    Write    interface physical ${phy}; qos service-policy ${policy_name} ingress
    Commit Testcase

    Switch Connection     SERVER
    Write    sudo python3 ${scripts_base_dir}/send_src_mac.py ${no_of_packet} ${server_iface} ${src_mac}
    ${cli}=     Read Until Prompt
    Should Contain     ${cli}     sent
    Sleep     5s 