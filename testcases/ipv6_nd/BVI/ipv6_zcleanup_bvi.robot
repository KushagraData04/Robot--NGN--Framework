*** Settings ***
Documentation       Configurations for BVI Interfaces IP Testing
Library             SSHLibrary
Library             Process
Library             String
Library             BuiltIn
Library             Collections
Variables           ../../../data/ipv4_arp.yaml
Resource            ../../../resource/common.resource

*** Test Cases ***
#################################
# BVI over Bundle Interface Setup & Cleanup
#################################

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

DUT1 Bundle Cleanup
   Switch Connection    ${DUT1.hostname}
   FOR    ${bundle}    IN    @{DUT1.bundle_interfaces}
     ${cli}=    Write   no interface bundle ${bundle.number}
   END
   Commit Testcase