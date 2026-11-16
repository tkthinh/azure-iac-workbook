targetScope = 'resourceGroup'
param serviceName string
param location string = resourceGroup().location
param skuName string = 'basic'
param tags object = {}
resource searchService 'Microsoft.Search/searchServices@2023-11-01' = {
  name: serviceName
  location: location
  tags: tags
  sku: { name: skuName }
  properties: {
    publicNetworkAccess: 'enabled'
    disableLocalAuth: false
  }
}
output id string = searchService.id
output name string = searchService.name
