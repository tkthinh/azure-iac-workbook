targetScope = 'resourceGroup'
param privateEndpointName string
param subnetResourceId string
param privateLinkResourceId string
param groupIds array
param location string = resourceGroup().location
param tags object = {}
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: { id: subnetResourceId }
    privateLinkServiceConnections: [{ name: 'default', properties: { privateLinkServiceId: privateLinkResourceId, groupIds: groupIds } }]
  }
}
output id string = privateEndpoint.id
