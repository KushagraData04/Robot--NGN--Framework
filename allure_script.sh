#!/bin/bash

# To run this order should be followed or this script can be called

# Reference - https://allurereport.org/docs/how-it-works/
#           - https://allurereport.org/docs/how-it-works/

# Remove last robot run files
rm -r allure-results
# Run robot testcase
robot --listener allure_robotframework:allure-results --pythonpath . testcases/l2/
# Copy previous report history in latest run history
cp -r allure-report/history allure-results/history
# Generate report from latest run data containing historical data
allure generate --clean
