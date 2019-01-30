# AllThree Demo

## Contacts
**Name:** Chris Wiederspan, Jordan Nielsen  
**Role:** Microsoft Azure App Dev Specialist 
**Email:** chris.wiederspan@microsoft.com, jonielse@microsoft.com

## Prerequisites

### Setup a Service Principal for use with AKS

Based on [this guidance](https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-service-principal), we will start by setting up a Service Principal that we'll use when creating an Azure AKS cluster.

`az login`  
`az ad sp create-for-rbac --name <YOUR_SP_NAME>`

You'll want to make a copy of the results, specifically the appId and password, as shown below.

![Credential screenshot](/assets/service-principal.png)

Finally, it's possible to test these values work as expected by first logging in:

`$ az login --service-principal -u CLIENT_ID -p CLIENT_SECRET --tenant TENANT_ID`

As we've obtained the credentials for this Service Principal - it's possible to configure them in a few different ways. A very common way is to use Environment Variables. 

Add these entries to the .bash_profile. 

```$ export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"

$ export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"

$ export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"

$ export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"

source .bash_profile
```

### Azure Resource Setup Using Terraform

We will use Terraform to create core infrastructure components in Azure. 
[Click here](https://www.terraform.io/docs/providers/azurerm/index.html) to read more about Terraform
and the Azure Resource Providers that it provides.

```bash
terraform init  
terraform apply  
```

First start with creating the Azure networking components.

1. Create VNET, Subnets, VNET Peering, Network Security Groups, Virtual Machine, NIC, and L4 Azure Load Balancer, and the Azure Firewall - [Click here](https://github.com/SouthwestAzure/allthree-infra-perm/tree/master/networking)

Before creating the AKS cluster, make sure and add your Service Principal credentials to the variables file in the aks-deploy folder. 

2. Create an AKS cluster that leverages Advanced Networking and places the cluster in a subnet created in step 1 - [Click here](https://github.com/SouthwestAzure/allthree-infra-perm/tree/master/aks-deploy)
