# Terraform Azure Verified Module template

This minimal AzAPI module template creates one Azure resource group.

## Telemetry

Telemetry is enabled by default. It creates an empty, incremental Azure deployment at the active subscription
scope using the module's `location`. The deployment identity needs `Microsoft.Resources/deployments/read`,
`Microsoft.Resources/deployments/write`, and `Microsoft.Resources/deployments/delete` permissions at that scope.
Telemetry deployment failures fail the apply. Set `enable_telemetry = false` to disable collection.

When upgrading from legacy telemetry, declarative `removed` blocks forget the old telemetry objects without
destroying them. Existing state may require the old `Azure/modtm` and `hashicorp/random` providers for one
final initialization. The root module no longer declares those telemetry-only provider requirements.
