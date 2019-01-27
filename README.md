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

We will use Terraform to create a Resource Group, Azure Container Registry and an AKS Cluster.
[Click here](https://www.terraform.io/docs/providers/azurerm/index.html) to read more about Terraform
and the Azure Resource Providers that it provides.

```bash
terraform init  
terraform apply  
```

You can expect this process to take between 10 to 15 minutes, mostly because AKS takes a while to provision in Azure.