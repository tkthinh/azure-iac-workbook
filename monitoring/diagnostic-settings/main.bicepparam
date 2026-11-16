using 'main.bicep'

param diagnosticSettingName = 'send-to-law'
param targetResourceId = '<target-resource-id>'
param workspaceResourceId = '<log-analytics-workspace-resource-id>'
param logCategories = []
param metricCategories = ['AllMetrics']
