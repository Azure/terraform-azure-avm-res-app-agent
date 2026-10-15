output "agent_endpoint" {
  description = "The endpoint URL of the SRE Agent."
  value       = try(azapi_resource.this.output.properties.agentEndpoint, null)
}

output "name" {
  description = "The name of the SRE Agent."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The exported properties of the SRE Agent resource (as specified in response_export_values)."
  value       = azapi_resource.this.output
}

output "resource_id" {
  description = "The resource ID of the SRE Agent."
  value       = azapi_resource.this.id
}

output "system_assigned_mi_principal_id" {
  description = "The principal ID of the system-assigned managed identity, if enabled."
  value       = try(azapi_resource.this.output.identity.principalId, null)
}
