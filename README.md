# TFAzureLAb
This repo can be used to spin up a small test env with the following resources

- vNet
     - No NSG's
     - Adjustable # of subnets, default is 2 subnets
- VM
     - With pip
     - Adjustable OS, default Win2k22 datacenter
     - Adjustable # disks, default 0
     - VM extensions for DSC v1.1 push scenarios
     - VM extensiosn for DSC v1.1 pull scenarios
     - VM extension to be used for DSC v2+ GuestConfiguration packages

- Azure Automation account

- Log Analytis workspace

- Storage account