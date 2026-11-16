targetScope = 'resourceGroup'

@description('Name of the Azure Monitor workspace.')
@minLength(3)
@maxLength(63)
param workspaceName string

@description('Azure region for the workspace. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Optional tags to apply to the workspace.')
param tags object = {}

// Azure Monitor Workspace (used by Azure Monitor managed service for Prometheus and related scenarios).
resource monitorWorkspace 'Microsoft.Monitor/accounts@2023-04-03' = {
  name: workspaceName
  location: location
  tags: tags
}

output workspaceName string = monitorWorkspace.name
output workspaceId string = monitorWorkspace.id
