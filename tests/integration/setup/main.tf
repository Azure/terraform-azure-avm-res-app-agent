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

variable "location" {
  type        = string
  default     = "centralindia"
  description = "The Azure region used for the integration test resource group."
}

data "azapi_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azapi_resource" "resource_group" {
  type      = "Microsoft.Resources/resourceGroups@2024-11-01"
  name      = "rg-avm-sre-agent-test-${random_string.suffix.result}"
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  location  = var.location
}

output "resource_group_id" {
  value       = azapi_resource.resource_group.id
  description = "The resource ID of the test resource group."
}

output "location" {
  value       = var.location
  description = "The location used for the test resources."
}

output "name_suffix" {
  value       = random_string.suffix.result
  description = "A random suffix for unique resource names."
}