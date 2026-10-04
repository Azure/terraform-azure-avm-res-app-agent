resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = var.resource_types.app_agents
  body = {
    properties = {
      actionConfiguration = var.action_configuration == null ? null : {
        accessLevel = var.action_configuration.access_level
        identity    = var.action_configuration.identity
        mode        = var.action_configuration.mode
      }
      agentIdentity = var.agent_identity == null ? null : {
        initialSponsorGroupId = var.agent_identity.initial_sponsor_group_id
      }
      agentSpaceId = var.agent_space_id
      defaultModel = var.default_model == null ? null : {
        name     = var.default_model.name
        provider = var.default_model.provider
      }
      incidentManagementConfiguration = var.incident_management_configuration == null ? null : {
        connectionName = var.incident_management_configuration.connection_name
        connectionUrl  = var.incident_management_configuration.connection_url
        oboUser        = var.incident_management_configuration.obo_user
        type           = var.incident_management_configuration.type
      }
      knowledgeGraphConfiguration = var.knowledge_graph_configuration == null ? null : {
        identity         = var.knowledge_graph_configuration.identity
        managedResources = var.knowledge_graph_configuration.managed_resources
      }
      logConfiguration = var.log_configuration == null ? null : {
        applicationInsightsConfiguration = var.log_configuration.application_insights_configuration == null ? null : {
          appId = var.log_configuration.application_insights_configuration.app_id
        }
      }
      upgradeChannel = var.upgrade_channel
    }
  }
  create_headers       = var.enable_telemetry ? { "User-Agent" = local.avm_azapi_header } : null
  delete_headers       = var.enable_telemetry ? { "User-Agent" = local.avm_azapi_header } : null
  ignore_body_changes  = length(var.ignore_body_changes.app_agents) > 0 ? var.ignore_body_changes.app_agents : null
  ignore_null_property = true
  read_headers         = var.enable_telemetry ? { "User-Agent" = local.avm_azapi_header } : null
  response_export_values = [
    "identity.principalId",
    "identity.tenantId",
    "properties.agentEndpoint",
    "properties.agentIdentity.clientId",
    "properties.agentIdentity.enabled",
  ]
  retry = var.retry
  sensitive_body = {
    properties = {
      incidentManagementConfiguration = var.connection_key == null ? null : {
        connectionKey = var.connection_key
      }
      logConfiguration = var.connection_string == null ? null : {
        applicationInsightsConfiguration = {
          connectionString = var.connection_string
        }
      }
    }
  }
  sensitive_body_version = {
    "properties.incidentManagementConfiguration.connectionKey"                      = var.connection_key_version
    "properties.logConfiguration.applicationInsightsConfiguration.connectionString" = var.connection_string_version
  }
  tags           = var.tags
  update_headers = var.enable_telemetry ? { "User-Agent" = local.avm_azapi_header } : null

  dynamic "identity" {
    for_each = var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0 ? [var.managed_identities] : []

    content {
      type = identity.value.system_assigned && length(identity.value.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : (
        identity.value.system_assigned ? "SystemAssigned" : "UserAssigned"
      )
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}
