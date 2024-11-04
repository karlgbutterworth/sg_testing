# sg_testing

## Summary
This tf script will create a scenario that has a few servers, a few subnets and security group implementations 

## Goal
- 1. 3 servers on 3 subnets
- 2. security groups in basic states to deny traffic connectivity
- 3. Ensure that modifications to the Security groups will not trigger a terminate on any instance
  - a. Perform update on the security group name as a "SG" modification
  - b. Perform update on the rules pertaining to the SG
- 4. Associated instances and SG
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
commit: c9e0b2de8ef52b7392d7563e743410b6c2bff4d5 (updated doc)


## Fix option 1 (attempot)
Disassociating the SG from the instance within TF directly and making the association manually should look to be one option to fix this
dependancy issue. 

commit: c9e0b2de8ef52b7392d7563e743410b6c2bff4d5

`tofu apply`

```
Apply complete! Resources: 16 added, 0 changed, 0 destroyed.
```

`tofu apply`

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

Added the security groups manually via console to all instances

`tofu apply`

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

Modified the security group name
commit: 

```
  # aws_security_group.allow_ping must be replaced
-/+ resource "aws_security_group" "allow_ping" {

...

      ~ name                   = "SG allow ICMP" -> "SG allow ICMP and HTTP" # forces replacement

...

Plan: 1 to add, 0 to change, 1 to destroy.
```

As expected, it will look to recreate the SG (and as it is currently associated with an instance will ultimately fail to be replaced)

```
Error: deleting Security Group (sg-0ee09575f64eada12): operation error EC2: DeleteSecurityGroup, https response error StatusCode: 400, RequestID: 9aaee1f2-44e3-49a8-85ab-5acf4a72d314, api error DependencyViolation: resource sg-0ee09575f64eada12 has a dependent object
```

Reverted the name of the SG, but left in the additional rule

commit: bb505598d0b3a7e76f6256495cf13d9e67620129

```
Plan: 0 to add, 1 to change, 0 to destroy.
```

This has the expeted results. 


### 4a
Apply the security group within the instance configuration

commit: 48e92e0d7e88eeaeb908ab5fe5f12281039ba1a7

`tofu apply`

`tofu apply`

```

      ~ security_groups                      = [ # forces replacement                                                                                         + "sg-039bcf370c3411ec9",                                                                                                                         ]
...

Plan: 3 to add, 0 to change, 3 to destroy.
```

We need to ensure we ignore the SG licecycle within the instance to avoid issues of isntances rebuilding. 

```
  lifecycle {                         
    ignore_changes = [security_groups]
  }                                   
```
commit: cb44d1a9180c79f62290578f32b30ebfb1847b72

`tofu apply`

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

Now to change the SG name - expectations are that the SG will not be able to be removed as it's attached, and ignored by the TF on the instance
 so will remain attached. 

commit: 41502baeee1853d493ef3b4da0e16b73d2dbcfb5

```
  # aws_security_group.allow_ping must be replaced
-/+ resource "aws_security_group" "allow_ping" {

...

      ~ name                   = "SG allow ICMP" -> "SG allow ICMP and test" # forces replacement
        # (5 unchanged attributes hidden)
    }

...

Plan: 1 to add, 0 to change, 1 to destroy.
```

```
 Error: deleting Security Group (sg-0ea3a4bf45c93d93f): operation error EC2: DeleteSecurityGroup, https response error StatusCode: 400, RequestID: c1e2cad1-9b70-4d0d-96f4-80287875571f, api error DependencyViolation: resource sg-0ea3a4bf45c93d93f has a dependent object
```

As expected. The only way to proceed with this is now to MANUALLY remove the SGs (A default SG *must* exist, so applying a default sg)

Once this has been completed:

```
Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```

NOTE:
Additional `tofu apply` does NOT apply the original security group or error.
This means that subsequent `apply` to the infrastructure WILL NOT re-apply the SG that was originally supplied.


`tofu destroy`


### 4b

`tofu apply`

```
Apply complete! Resources: 16 added, 0 changed, 0 destroyed.
```

`tofu apply`

```
No changes. Your infrastructure matches the configuration.
```

Added extra rule into the SG

commit: b2a97dc1a47d1158d42a82bf21d014e272050916
commit: befdac6297aa43263f07dfdf8b5e0493fa64cdf6

`tofu apply`

Plan: 0 to add, 1 to change, 0 to destroy.

```
Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```


# Results
Either:
- only associate the SGs manually to ensure that there is no destruction to instances
- ensure that a licecycle attribute for the TF instances exists to ignore updates on the SG association. 

