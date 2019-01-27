# AllThree Demo

## Contacts
**Name:** Chris Wiederspan  
**Role:** Microsoft Azure App Dev Specialist  
**Email:** chris.wiederspan@microsoft.com

## Prerequisites

### Setup a Service Principal for use with AKS

Based on [this guidance](https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-service-principal), we will start by setting up a Service Principal that we'll use when creating an Azure AKS cluster.

`az login`  
`az ad sp create-for-rbac --name <YOUR_SP_NAME>`

You'll want to make a copy of the results, specifically the appId and password, as shown below.

![Credential screenshot](/assets/service-principal.png)

### Azure Resource Setup Using Terraform

We will use Terraform to create core infrastructure components in Azure. 
[Click here](https://www.terraform.io/docs/providers/azurerm/index.html) to read more about Terraform
and the Azure Resource Providers that it provides.

```bash
terraform init  
terraform apply  
```

First start with creating the Azure networking components.

Create VNET & VNET Peering - [Click here](https://github.com/SouthwestAzure/allthree-infra-perm/tree/master/vnet-peering)

Create Network Security Grooup - [Click here](https://github.com/SouthwestAzure/allthree-infra-perm/blob/master/nsg/main.tf)

Create Virtual Machine, Network Interface Card, and L4 Load Balancer - 

