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
### 3.
Single main.tf for testing

`tofu apply`

```
Plan: 3 to add, 0 to change, 3 to destroy.
```

Repeat the apply (as attached to an SG):

`tofu apply`

```
  # aws_instance.instance_c must be replaced
-/+ resource "aws_instance" "instance_c" {
...
      ~ security_groups                      = [ # forces replacement
          + "sg-000a061676d198a75",
        ]
...
```

```
Plan: 3 to add, 0 to change, 3 to destroy.
```

This suggests that merely being associated with an SG directly that it will look to be rebuilt

commit: 870fabdeda6ba0f85f9ecfc20b1a55d11de0c48d


## Fix option 1 (attempot)
Disassociating the SG from the instance within TF directly and making the association manually should look to be one option to fix this
dependancy issue. 





### 3a
Change the security group name

`tofu apply`

### 3b

# Results


