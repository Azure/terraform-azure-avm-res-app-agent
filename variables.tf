// =====================================================
// Required inputs
// =====================================================

variable "location" {
  type        = string
  description = "The Azure region where the SRE Agent will be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the SRE Agent."
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z]([-A-Za-z0-9]{0,30}[A-Za-z0-9])$", var.name))
    error_message = "The name must be 2 to 32 characters, start with a letter, end with an alphanumeric character, and contain only letters, numbers, and hyphens."
  }
}

variable "parent_id" {
  type        = string
  nullable    = false
  description = <<DESCRIPTION
The fully-qualified ARM resource ID of the resource group into which the SRE Agent will be deployed, for example `/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg`.

This module does not create the parent scope. The consumer is responsible for providing an existing resource group ID.
DESCRIPTION

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id))
    error_message = "`parent_id` must be a valid resource group resource ID."
  }
}

// =====================================================
// SRE Agent configuration (Microsoft.App/agents schema)
// =====================================================

variable "action_configuration" {
  type = object({
    access_level = optional(string)
    identity     = optional(string)
    mode         = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Configuration for action.

- `access_level` - The access level of the action. Possible values are `High` and `Low`.
- `identity` - The identity used by the action.
- `mode` - The mode of the action. Possible values are `Autonomous`, `ReadOnly`, and `Review`.
DESCRIPTION
}

variable "agent_identity" {
  type = object({
    initial_sponsor_group_id = string
  })
  default     = null
  description = <<DESCRIPTION
Agent identity configuration for accessing resources.

- `initial_sponsor_group_id` - Initial sponsor group ID (required for agent identity).
DESCRIPTION
}

variable "agent_space_id" {
  type        = string
  default     = null
  description = "The agent space ID referenced by the agent."
}

variable "default_model" {
  type = object({
    name     = optional(string)
    provider = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Default AI model configuration for the agent.

- `name` - Model name (e.g., gpt-5, claude-opus-4-5, claude-sonnet-4-5).
- `provider` - AI provider name (e.g., MicrosoftFoundry, Anthropic).
DESCRIPTION
}

variable "incident_management_configuration" {
  type = object({
    connection_name = optional(string)
    connection_url  = optional(string)
    obo_user        = optional(string)
    type            = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Incident management configuration. The secret `connection_key` is supplied separately through the write-only `connection_key` variable.

- `connection_name` - The name of the connection.
- `connection_url` - The URL of the connection.
- `obo_user` - The user for the connection.
- `type` - The type of incident management system.
DESCRIPTION
}

variable "knowledge_graph_configuration" {
  type = object({
    identity          = optional(string)
    managed_resources = optional(list(string))
  })
  default     = null
  description = <<DESCRIPTION
Knowledge graph configuration for the agent.

- `identity` - The identity used to access the knowledge graph.
- `managed_resources` - The list of resource IDs managed by the agent.
DESCRIPTION
}

variable "log_configuration" {
  type = object({
    application_insights_configuration = optional(object({
      app_id = optional(string)
    }))
  })
  default     = null
  description = <<DESCRIPTION
Log configuration. The secret Application Insights `connection_string` is supplied separately through the write-only `connection_string` variable.

- `application_insights_configuration` - Application Insights configuration.
  - `app_id` - The Application ID for the Application Insights resource.
DESCRIPTION
}

variable "upgrade_channel" {
  type        = string
  default     = null
  description = "The upgrade channel of the agent. Possible values are `Preview` and `Stable`."
}

// =====================================================
// Write-only secrets
// =====================================================

variable "connection_key" {
  type        = string
  ephemeral   = true
  default     = null
  description = "The key for the incident management connection. Supplied as a write-only value so it is never persisted in state."
}

variable "connection_key_version" {
  type        = number
  default     = null
  description = "Version tracker for `connection_key`. Increment to force the secret to be re-sent to Azure."

  validation {
    condition     = var.connection_key == null || var.connection_key_version != null
    error_message = "When `connection_key` is set, `connection_key_version` must also be set."
  }
}

variable "connection_string" {
  type        = string
  ephemeral   = true
  default     = null
  description = "The connection string for the Application Insights resource. Supplied as a write-only value so it is never persisted in state."
}

variable "connection_string_version" {
  type        = number
  default     = null
  description = "Version tracker for `connection_string`. Increment to force the secret to be re-sent to Azure."

  validation {
    condition     = var.connection_string == null || var.connection_string_version != null
    error_message = "When `connection_string` is set, `connection_string_version` must also be set."
  }
}

// =====================================================
// AVM interfaces
// =====================================================

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "ignore_body_changes" {
  type = object({
    app_agents = optional(list(string), [])
  })
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
A set of `body` paths whose changes should be ignored, keyed by the module's AzAPI resource. Paths use dot notation (for example `properties.upgradeChannel`). Changes take effect only after an apply because the value is stored in provider-private state.

- `app_agents` - Paths to ignore on the `Microsoft.App/agents` resource.
DESCRIPTION
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
Controls the Managed Identity configuration on this resource.

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
DESCRIPTION
}

variable "resource_types" {
  type = object({
    app_agents          = optional(string, "Microsoft.App/agents@2026-01-01")
    authorization_locks = optional(string, "Microsoft.Authorization/locks@2020-05-01")
  })
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
The AzAPI resource type (including API version) for each resource the module manages. Override to target a specific API version or a sovereign cloud.

- `app_agents` - The resource type for the SRE Agent. Defaults to `Microsoft.App/agents@2026-01-01`.
- `authorization_locks` - The resource type for the management lock. Defaults to `Microsoft.Authorization/locks@2020-05-01`.
DESCRIPTION
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = <<DESCRIPTION
Retry configuration applied to the AzAPI resource. Defaults to `null` (no custom retry).

- `error_message_regex` - (Optional) A list of regex patterns matching error messages that trigger a retry.
- `interval_seconds` - (Optional) Initial interval between retries in seconds.
- `max_interval_seconds` - (Optional) Maximum interval between retries in seconds.
DESCRIPTION
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "A map of tags to assign to the SRE Agent."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Per-operation timeouts applied to the AzAPI resource. Defaults to `null` (provider defaults). Each value is a Go duration string (for example `30m`, `1h`).

- `create` - (Optional) Timeout for create operations.
- `read` - (Optional) Timeout for read operations.
- `update` - (Optional) Timeout for update operations.
- `delete` - (Optional) Timeout for delete operations.
DESCRIPTION
}
