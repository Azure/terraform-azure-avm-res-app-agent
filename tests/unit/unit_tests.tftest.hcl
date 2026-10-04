mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.App/agents/sre-agent-test"
    }
  }
}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  location  = "eastus"
  name      = "sre-agent-test"
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg"
}

run "defaults" {
  command = apply

  assert {
    condition     = azapi_resource.this.type == "Microsoft.App/agents@2026-01-01"
    error_message = "The module must deploy the SRE Agent with the expected default API version."
  }

  assert {
    condition     = azapi_resource.this.name == var.name
    error_message = "The agent name must match the module input."
  }

  assert {
    condition     = azapi_resource.this.parent_id == var.parent_id
    error_message = "The agent parent_id must match the module input."
  }

  assert {
    condition     = output.resource_id == azapi_resource.this.id
    error_message = "The resource_id output must match the agent resource ID."
  }

  assert {
    condition     = output.name == var.name
    error_message = "The name output must match the agent name."
  }

  assert {
    condition     = length(azapi_resource.lock) == 0
    error_message = "No lock should be created by default."
  }

  assert {
    condition     = length(azapi_resource.role_assignments) == 0
    error_message = "No role assignments should be created by default."
  }

  assert {
    condition     = length(modtm_telemetry.telemetry) == 1
    error_message = "Telemetry should be enabled by default."
  }
}

run "telemetry_disabled" {
  command = apply

  variables {
    enable_telemetry = false
  }

  assert {
    condition     = length(modtm_telemetry.telemetry) == 0
    error_message = "No telemetry resource should be created when enable_telemetry is false."
  }

  assert {
    condition     = length(random_uuid.telemetry) == 0
    error_message = "No telemetry random_uuid should be created when enable_telemetry is false."
  }
}

run "system_assigned_identity" {
  command = apply

  variables {
    managed_identities = {
      system_assigned = true
    }
  }

  assert {
    condition     = one(azapi_resource.this.identity).type == "SystemAssigned"
    error_message = "A system-assigned identity should produce an identity block of type SystemAssigned."
  }
}

run "lock_created" {
  command = apply

  variables {
    lock = {
      kind = "CanNotDelete"
    }
  }

  assert {
    condition     = length(azapi_resource.lock) == 1
    error_message = "A lock should be created when var.lock is set."
  }

  assert {
    condition     = azapi_resource.lock[0].name == "lock-${var.name}"
    error_message = "The lock name should default to lock-<agent name>."
  }

  assert {
    condition     = azapi_resource.lock[0].type == "Microsoft.Authorization/locks@2020-05-01"
    error_message = "The lock must use the configured lock resource type."
  }
}

run "role_assignment_created" {
  command = apply

  variables {
    role_assignment_definition_lookup_enabled = false
    role_assignments = {
      admin = {
        role_definition_id_or_name = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
        principal_id               = "00000000-0000-0000-0000-000000000002"
      }
    }
  }

  assert {
    condition     = length(azapi_resource.role_assignments) == 1
    error_message = "One role assignment should be created."
  }
}

run "invalid_name" {
  command = plan

  variables {
    name = "1-invalid-start"
  }

  expect_failures = [var.name]
}

run "invalid_parent_id" {
  command = plan

  variables {
    parent_id = "not-a-valid-resource-id"
  }

  expect_failures = [var.parent_id]
}

run "connection_key_requires_version" {
  command = plan

  variables {
    connection_key = "secret-value"
  }

  expect_failures = [var.connection_key_version]
}