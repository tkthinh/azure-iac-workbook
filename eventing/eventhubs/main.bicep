targetScope = 'resourceGroup'
param namespaceName string
param eventHubName string
param location string = resourceGroup().location
param tags object = {}
resource namespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: namespaceName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}
resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: namespace
  name: eventHubName
  properties: {
    messageRetentionInDays: 1
    partitionCount: 2
  }
}
output namespaceId string = namespace.id
output eventHubId string = eventHub.id
