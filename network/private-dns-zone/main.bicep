targetScope = 'resourceGroup'
param zoneName string
param virtualNetworkResourceId string
param tags object = {}
resource zone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: zoneName
  tags: tags
}
resource link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: zone
  name: '${last(split(virtualNetworkResourceId, '/'))}-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetworkResourceId
    }
    registrationEnabled: false
  }
}
output id string = zone.id
