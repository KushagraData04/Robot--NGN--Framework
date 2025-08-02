*** Settings ***
Library             Process
Library             OperatingSystem
Library             SSHLibrary
Variables           data/l2_suite.yaml

*** Keywords ***
Check Monit Status
    FOR    ${process}    IN    @{MonitProcess}
        Write     monit status ${process} | grep "status"
        ${cli}=    Read Until Prompt
        Should Contain    ${cli}    OK
    END 