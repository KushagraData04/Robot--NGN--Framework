*** Settings ***
Documentation       Configurations for BVI Interfaces IP Testing
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Variables           ../../data/ipv4.yaml
Resource            ../../resource/common.resource


*** Test Cases ***
#################################
#bvi over bundle inteface cleanup
#################################

# Server Subif Interface Deletion
#    [Documentation]  Configure to  ${Server158.hostname}
#    Switch Connection    ${Server158.hostname}
#    # Create VLAN Interfaces and Assign IP addresses to interfaces inside namespaces
#    Write  sudo su
#    Sleep  2s
#    Write  ngn@8737
#    Write  ip netns exec ns-pega-228 ip link delete eno12399np0.10 
#    Write  ip netns exec ns-pega-229 ip link delete eno12409np1.20 

BVI over Bundle Interface Configuration DUT1
  [Documentation]  BVI over PHY Interfaces Configuration
  Switch Connection    ${DUT1.hostname}
    Write   top;
    FOR    ${bvi}    IN    @{DUT1.bundle_bvi_interfaces}
      Write   bridge default; vlan ${bvi.allowed_vlan}; irb disable; 
      Commit Testcase
      Write   bridge default 
      Sleep   1s
      Write   no interface ${bvi.port}  
      Commit Testcase
    END

BVI over Bundle Interface Configuration DUT2
  [Documentation]  BVI over PHY Interfaces Configuration
  Switch Connection    ${DUT2.hostname}
    Write   top;
    FOR    ${bvi}    IN    @{DUT2.bundle_bvi_interfaces}
      Write   bridge default; vlan ${bvi.allowed_vlan}; irb disable; 
      Commit Testcase
      Write   bridge default 
      Sleep   1s
      Write   no interface ${bvi.port}  
      Commit Testcase
    END


DUT1 Bundle Cleanup
   Switch Connection    ${DUT1.hostname}
   FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=    Write   no interface bundle ${bundle.number}
   END
   Commit Testcase

DUT2 Bundle Cleanup
   Switch Connection    ${DUT2.hostname}
   FOR    ${bundle}    IN    @{DUT2.bundle_interfaces}
      ${cli}=    Write   no interface bundle ${bundle.number}
   END
   Commit Testcase

Ping Test
  Switch Connection  ${Server158.hostname}
  # Read Until Prompt
  Write    sudo ip netns exec ns-pega-228 ping 20.20.20.158 -c 10 > noping5.txt
  Sleep    1s
  Write    ngn@8737
  Sleep    10s
  Read Until Prompt
  Open Connection    ${Server}    alias=${Server158.hostname}    prompt=$    timeout=${DUT_TIMEOUT}    port=${DUT2.ssh_port}
  Login    ngn    ngn@8737
  Write    cat noping5.txt
  ${cli}    Read Until Prompt
  Should Contain    ${cli}     100% packet loss
  Close Connection

Server Subif Interface Deletion
  [Documentation]  Configure to  ${Server158.hostname}
  Switch Connection    ${Server158.hostname}
  # Create VLAN Interfaces and Assign IP addresses to interfaces inside namespaces
  Write  sudo su
  Sleep  2s
  Write  ngn@8737
  Write  ip netns exec ns-pega-228 ip link delete eno12399np0.10 
  Write  ip netns exec ns-pega-229 ip link delete eno12409np1.20 