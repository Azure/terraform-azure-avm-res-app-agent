run "setup" {
  command = apply

  module {
    source = "./tests/integration/setup"
  }
}

run "create_agent" {
  command = apply

  variables {
    name      = "sre-agent-${run.setup.name_suffix}"
    location  = run.setup.location
    parent_id = run.setup.resource_group_id

    managed_identities = {
      system_assigned = true
    }
  }

  assert {
    condition     = output.resource_id == azapi_resource.this.id
    error_message = "The resource_id output must match the created agent ID."
  }

  assert {
    condition     = output.name == var.name
    error_message = "The name output must match the agent name."
  }

  assert {
    condition     = azapi_resource.this.type == "Microsoft.App/agents@2026-01-01"
    error_message = "The agent must be created with the expected API version."
  }
}