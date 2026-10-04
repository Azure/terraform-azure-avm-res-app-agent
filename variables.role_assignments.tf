variable "role_assignment_definition_lookup_enabled" {
  type        = bool
  default     = true
  nullable    = false
  description = <<DESCRIPTION
Controls whether role definitions are looked up by name when creating role assignments. When disabled, every role assignment must supply `role_definition_id_or_name` as a full role definition resource ID.
DESCRIPTION
}

variable "role_assignment_definition_scope" {
  type        = string
  default     = null
  description = "The scope used to look up role definitions by name. Defaults to the SRE Agent resource ID when not set."
}

variable "role_assignments" {
  type = map(object({
    name                                   = optional(string, null)
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
A map of role assignments to create on the SRE Agent. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

- `name` - (Optional) The name (a GUID) of the role assignment. A random UUID is generated when omitted.
- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - (Optional) The description of the role assignment.
- `skip_service_principal_aad_check` - (Optional) No effect when using AzAPI.
- `condition` - (Optional) The condition which will be used to scope the role assignment.
- `condition_version` - (Optional) The version of the condition syntax. Valid value is `2.0`.
- `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource ID which contains a Managed Identity. Used in cross-tenant scenarios.
- `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group`, and `ServicePrincipal`.
DESCRIPTION
}
