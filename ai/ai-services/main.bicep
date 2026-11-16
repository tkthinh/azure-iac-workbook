targetScope = 'resourceGroup'
param accountName string
param location string = resourceGroup().location
param skuName string = 'S0'
param tags object = {}
resource account 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: accountName
  location: location
  tags: tags
  kind: 'CognitiveServices'
  sku: { name: skuName }
  properties: {
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
  }
}
output id string = account.id
output endpoint string = account.properties.endpoint
