targetScope = 'resourceGroup'
param namespaceName string
param location string = resourceGroup().location
param skuName string = 'Standard'
param tags object = {}
resource namespace 'Microsoft.ServiceBus/namespaces@2024-01-01' = {
  name: namespaceName
  location: location
  tags: tags
  sku: { name: skuName, tier: skuName }
  properties: { publicNetworkAccess: 'Enabled', minimumTlsVersion: '1.2' }
}
output id string = namespace.id
output endpoint string = namespace.properties.serviceBusEndpoint
