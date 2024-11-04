# sg_testing

## Summary
This tf script will create a scenario that has a few servers, a few subnets and security group implementations 

## Goal
- 1. 3 servers on 3 subnets
- 2. security groups in basic states to deny traffic connectivity
- 3. Ensure that modifications to the Security groups will not trigger a terminate on any instance
  - a. Perform update on the security group name as a "SG" modification
  - b. Perform update on the rules pertaining to the SG

## Execution
Single main.tf for testing

`tofu apply`



### 3a

### 3b

# Results


