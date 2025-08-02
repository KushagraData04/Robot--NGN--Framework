# Testing using Robot Framework

### DO NOT SAVE/USE ROOT PASSWORD IN VARIABLES/TESTCASES

Key based logins to our devices have following two steps

1.  Get your ssh RSA key signed from [NGN keysign server](http://192.168.3.9/keysign.html).
```bash
        - Input your public key content (~/.ssh/id_rsa.pub). Assuming all of you have SSH keys in order to clone from gitlab. Otherwise follow http://192.168.3.53:8080/help/ssh 
        - It would output a signed certificate. Save that as ~/.ssh/id_rsa-cert.pub in your machine.
        - The certificate would be valid for 1 year. Get it re-signed after that period.
        - With this you will have password less authentication to all our MTBR based stacks (MTBR, HSRS, SPIC).
```

2. Router end configuration
```bash
    router(config)# AAA authentication ssh-trusted-user-CA-public-key "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBk5Gmj5tspr1QQQ+RfYLrRuDYUekYfgO752d9+wgk9Pd6/BztN0UN9Xz2Xet2cihTomWc+n8zWFIF9+vvn+Cq8= cdot@ngn-srv-2"
    router(config)# commit
```

## Prerequisites

Before running the code below, ensure the following prerequisites are met:

1. Change DUT rootsystem login password from default to `Root@123`.
2. Enable packet stats timer from `ldbg` using `sys stats_timer_dur_ms 5`.
3. Ensure the name of DUT is the same as the one defined in `data/dut.yaml` prompt. If not, change it using the command `system cli hostname <prompt-name-without#>`.

## Repository Structure

The repository contains 3 subdirectories:

1. **Tests**: Contains folders having robot codes checking a particular functionality of the DUT along with Python scripts used for packet injection.
2. **Data**: Stores all the variables used by a particular DUT in YAML format.
3. **Resource**: Contains files for commonly used functions/checks in robot code.
3. **Python_codes**: Contains codes to be run on server from robot code for packet injection 

## Installation Steps for Robot Framework

To install Robot Framework on a new system, follow these steps:

```bash
mkdir -p ~/robot/python/
python3 -m venv ~/robot/python/
source ~/robot/python/bin/activate
pip3 install robotframework
pip3 install robotframework-netmiko
```


Additionally, if you want to inject packets to test few functionalities, you need to make a physical connection between the source server and DUT. 
## Commands to Test Device using Robot Framework 
From the root directory, run the following command:
 ```bash
  sudo robot --pythonpath . <path of robot directory>(tests/) 
  ```
[NOTE: sudo permission is required only for packet injection]

## Test case organization
**Tests**:
    • **Common** : Robot testcases common to all targets arranged module wise.
    • **Release** : Robot testcases for a particular target, organised into target wise folders i.e. spt/ falcon/ etc. further arranged module wise.

## Output Generated :
Robot framework generates three output files in root directory i.e report.html, log.html and output.xml containing all the results and CLI outputs of the test.





## Visual Studio Setup

1. Create venv, use venv, then in terminal install following python packages
    
    ```bash
	pip3 install robotframework
	pip3 install robotframework-sshlibrary
	pip3 install pyyaml
    ```

2. In settings.json of RobotCode extension add following

    ```bash
    "robotcode.robot.pythonPath": [
    "./"
    ],
    ```
### File naming Convention ###
Try to keep file name created for variable same as testcases. For example

```bash
    data/mpls.yaml
    testcases/mpls.robot
```