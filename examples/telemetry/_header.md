# Telemetry-enabled example

This deploys the module with AVM telemetry explicitly enabled (`enable_telemetry = true`, which is also the module default).
Telemetry uses an empty, incremental AzAPI deployment at the active subscription scope in the module's `location`.
The deployment name encodes the module identifier, version, source category, and instance hash.

The deployment identity needs `Microsoft.Resources/deployments/read`, `Microsoft.Resources/deployments/write`,
and `Microsoft.Resources/deployments/delete` permissions at subscription scope.
Telemetry deployment failures fail the apply. Set `enable_telemetry = false` to disable collection.
See <https://aka.ms/avm/telemetryinfo> and the Data Collection notice below.
