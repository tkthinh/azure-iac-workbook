targetScope = 'resourceGroup'

@description('Principal ID of a managed identity.')
param principalId string
@description('Built-in or custom role definition GUID, not its display name.')
param roleDefinitionGuid string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalId, roleDefinitionGuid)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionGuid)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

output roleAssignmentId string = roleAssignment.id
