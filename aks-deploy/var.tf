variable "client_id" {
    default = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

}
variable "client_secret" {
    default = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

}

variable "resource_group_name" {
    default = "k8s"

}


variable "agent_count" {
    default = 3
}

variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
    default = "k8stest"
}

variable cluster_name {
    default = "k8stest"
}

variable location {
    default = "West US 2"
}

variable log_analytics_workspace_name {
    default = "jnk8sLogAnalyticsWorkspaceName"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
    default = "West US 2"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "Standard"
}
