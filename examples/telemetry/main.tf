terraform {
  required_version = ">= 1.11, < 2.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azapi" {}

data "azapi_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Supporting resource group for the SRE Agent (created with AzAPI per AVM rules).
resource "azapi_resource" "resource_group" {
  type      = "Microsoft.Resources/resourceGroups@2024-11-01"
  name      = "rg-avm-sre-agent-telemetry-${random_string.suffix.result}"
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  location  = "centralindia"
}

module "sre_agent" {
  source = "../../"

  location  = "centralindia"
  name      = "sre-agent-${random_string.suffix.result}"
  parent_id = azapi_resource.resource_group.id

  # Telemetry is explicitly enabled (this is also the module default).
  enable_telemetry = true

  managed_identities = {
    system_assigned = true
  }

  tags = {
    environment = "example"
    scenario    = "telemetry"
  }
}
