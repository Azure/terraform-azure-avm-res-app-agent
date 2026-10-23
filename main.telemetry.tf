data "azapi_client_config" "telemetry" {
  count = var.enable_telemetry ? 1 : 0
}

data "modtm_module_source" "telemetry" {
  count = var.enable_telemetry ? 1 : 0

  module_path = path.module
}

locals {
  # If your module does not support a location, then set this local to "unknown"
  # If the location is sourced from a collection or other value, then you can update this local to set it to the location
  main_location = var.location
}

resource "random_uuid" "telemetry" {
  count = var.enable_telemetry ? 1 : 0
}

resource "modtm_telemetry" "telemetry" {
  count = var.enable_telemetry ? 1 : 0
}

removed {
  from = modtm_telemetry.telemetry
  lifecycle {
    destroy = false
  }
}

resource "azapi_resource" "telemetry" {
  count = var.enable_telemetry ? 1 : 0

  location  = local.main_location
  name      = "${local.avm_metadata.telemetryIdPrefix}.${local.avm_telemetry_version_token}.${local.avm_module_source_type}.${substr(sha1(terraform_data.telemetry[0].id), 0, 4)}"
  parent_id = one(data.azapi_client_config.telemetry).subscription_resource_id
  type      = "Microsoft.Resources/deployments@2025-04-01"
  body = {
    properties = {
      mode = "Incremental"
      template = {
        "$schema"      = "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#"
        contentVersion = "1.0.0.0"
        resources      = []
        outputs = {
          telemetry = {
            type  = "String"
            value = "For more information, see https://aka.ms/avm/TelemetryInfo"
          }
          apply_id = {
            type  = "String"
            value = plantimestamp()
          }
        }
      }
    }
  }
  response_export_values = []

  lifecycle {
    precondition {
      condition     = length(local.avm_metadata.telemetryIdPrefix) + length(local.avm_telemetry_version_token) + 8 <= 64 && can(regex("^[A-Za-z0-9_-]+$", local.avm_telemetry_version_token))
      error_message = "The telemetry deployment name must fit Azure's 64-character limit and contain a valid module version."
    }
  }
}

locals {
  avm_azapi_headers = !var.enable_telemetry ? {} : (local.fork_avm ? {
    fork_avm  = "true"
    random_id = one(random_uuid.telemetry).result
    } : {
    avm                = "true"
    random_id          = one(random_uuid.telemetry).result
    avm_module_source  = one(data.modtm_module_source.telemetry).module_source
    avm_module_version = one(data.modtm_module_source.telemetry).module_version
  })
}

locals {
  fork_avm = !anytrue([for r in local.valid_module_source_regex : can(regex(r, one(data.modtm_module_source.telemetry).module_source))])
}

locals {
  valid_module_source_regex = [
    "registry.terraform.io/[A|a]zure/.+",
    "registry.opentofu.io/[A|a]zure/.+",
    "git::https://github\\.com/[A|a]zure/.+",
    "git::ssh:://git@github\\.com/[A|a]zure/.+",
  ]
}

locals {
  # tflint-ignore: terraform_unused_declarations
  avm_azapi_header = join(" ", [for k, v in local.avm_azapi_headers : "${k}=${v}"])
}
