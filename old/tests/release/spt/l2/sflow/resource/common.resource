*** Settings ***
Library             NetmikoLibrary
Library             Process
Library             OperatingSystem

*** Keywords ***
Connect to Device
    Open Connection      test-device2    ${ip}   cisco_ios    rootsystem          Root@123        port=22     timeout=60
    ${cli}=             Cli    config; system cli prompt2 ${prompt}; commit; exit

Commit Testcase
    ${cli}=             Cli    commit;
    Should Contain Any    ${cli}    Commit complete    No modifications to commit


