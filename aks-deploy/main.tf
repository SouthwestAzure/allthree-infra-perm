data "azurerm_resource_group" "hub" {
    name     = "myrg"
}

data "azurerm_log_analytics_workspace" "workshop" {
    name      		= "jnworkspace38394"
    resource_group_name = "${data.azurerm_resource_group.hub.name}"
}


#resource "azurerm_log_analytics_solution" "test" {
#    solution_name         = "ContainerInsights"
#    location              = "West US 2"
#    resource_group_name   = "${data.azurerm_resource_group.hub.name}"
#    workspace_resource_id = "${data.azurerm_log_analytics_workspace.workshop.workspace_id}"
#    workspace_name        = "${data.azurerm_log_analytics_workspace.workshop.name}"
#
#    plan {
#        publisher = "Microsoft"
#        product   = "OMSGallery/ContainerInsights"
#    }
#}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = "all3cluster"
    location            = "West US 2"
    resource_group_name = "${data.azurerm_resource_group.hub.name}"
    dns_prefix          = "all3cluster"

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = "${file("${var.ssh_public_key}")}"
        }
    }

    agent_pool_profile {
        name            = "agentpool"
        count           = "${var.agent_count}"
        vm_size         = "Standard_DS1_v2"
        os_type         = "Linux"
        os_disk_size_gb = 30
    }

    service_principal {
        client_id     = "${var.client_id}"
        client_secret = "${var.client_secret}"
    }

    addon_profile {
        oms_agent {
        enabled                    = true
        log_analytics_workspace_id = "${data.azurerm_log_analytics_workspace.workshop.id}"
        }
    }

    tags {
        Environment = "Development"
    }
}
