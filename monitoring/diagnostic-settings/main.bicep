targetScope = 'resourceGroup'

@description('Name of the diagnostic setting.')
param diagnosticSettingName string
@description('Resource ID of the resource emitting diagnostics.')
param targetResourceId string
@description('Resource ID of the destination Log Analytics workspace.')
param workspaceResourceId string
@description('Diagnostic log categories to enable.')
param logCategories array
@description('Diagnostic metric categories to enable.')
param metricCategories array = []

// Diagnostic settings are extension resources. A reusable module must be
// deployed at the target resource's scope by its consuming stack.
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingName
  properties: {
    workspaceId: workspaceResourceId
    logs: [for category in logCategories: {
      category: category
      enabled: true
    }]
    metrics: [for category in metricCategories: {
      category: category
      enabled: true
    }]
  }
}

output id string = diagnosticSettings.id
